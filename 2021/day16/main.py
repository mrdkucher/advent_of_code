from typing import List
import binascii


SUM_OP = 0
PROD_OP = 1
MIN_OP = 2
MAX_OP = 3
LITERAL_VALUE = 4
GT_OP = 5
LT_OP = 6
EQ_OP = 7
BIT_LENGTH = 0
PACKET_COUNT = 1


def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.read().strip()


class Packet:
    def __init__(self, packet_version: int, packet_type: int):
        self.version = packet_version
        self.type = packet_type

        self.value = None
        self.subpackets = []
    
    def __str__(self, depth=0):
        if depth == 0:
            divider = '\n\t'
        else:
            divider = '\n' + '\t' * depth

        my_str = f'V: {self.version}, T: {self.type}'
        
        if self.value is not None:
            my_str += f', v: {self.value}'

        if len(self.subpackets) > 0:
            subpackets = divider.join([p.__str__(depth=depth+1) for p in self.subpackets])
            my_str += f', SUBPACKETS:{divider}{subpackets}'

        return my_str


def bits2int(bitarray):
    length = len(bitarray)
    value = 0
    for i, val in enumerate(bitarray):
        value += val << (length - 1 - i)
    return value


def bits2str(bitarray):
    return f'0b{"".join([str(b) for b in bitarray])}'


def hex2binarray(hex_str):
    binarray = []
    for byte in binascii.unhexlify(hex_str):
        for i in range(8):
            binarray.append((byte >> 7 - i) & 1)
    return binarray


def strip_version(binarray):
    version_bits = binarray[:3]
    version = bits2int(version_bits)
    return version, binarray[3:]


def strip_type(binarray):
    type_bits = binarray[:3]
    t = bits2int(type_bits)
    return t, binarray[3:]


def strip_literal_value(bitarray: List[int], packet: Packet):
    found_leading_zero = False
    data = []
    while not found_leading_zero:
        found_leading_zero = bitarray[0] == 0
        value_bits = bitarray[1:5]
        data.extend(value_bits)
        bitarray = bitarray[5:]
    literal_value = bits2int(data)
    packet.value = literal_value

    return bitarray


def strip_operator(bitarray: List[int], packet: Packet):
    length_type_id = bitarray.pop(0)
    if length_type_id == BIT_LENGTH:
        sub_packet_num_bits = bits2int(bitarray[:15])
        bitarray = bitarray[15:]

        sub_bitarray = bitarray[:sub_packet_num_bits]
        bitarray = bitarray[sub_packet_num_bits:]

        while len(sub_bitarray) > 0:
            sub_packet, sub_bitarray = parse_single_packet(sub_bitarray)
            packet.subpackets.append(sub_packet)

    elif length_type_id == PACKET_COUNT:
        num_sub_packets = bits2int(bitarray[:11])

        bitarray = bitarray[11:]
        for _ in range(num_sub_packets):
            sub_packet, bitarray = parse_single_packet(bitarray)
            packet.subpackets.append(sub_packet)
    else:
        raise ValueError(f'Unexpected value {length_type_id} is no 0 or 1')

    return bitarray


def parse_single_packet(bitarray: List[int]):
    # Ignore extra bits due to hexadecimal representation
    if len(bitarray) < 8:
        return None, []

    version, bitarray = strip_version(bitarray)
    btype, bitarray = strip_type(bitarray)

    packet = Packet(version, btype)

    if btype == LITERAL_VALUE:
        bitarray = strip_literal_value(bitarray, packet)
    else:
        bitarray = strip_operator(bitarray, packet)

    return packet, bitarray


def parse_packets(bitarray: List[int]):
    packets = []

    while len(bitarray) > 0:
        
        packet, bitarray = parse_single_packet(bitarray)
        if packet is not None:
            packets.append(packet)

    return packets


def count_versions(packets: List[Packet]):
    version_count = 0
    for packet in packets:
        version_count += packet.version
        version_count += count_versions(packet.subpackets)
    return version_count


def evaluate_packets(packets: List[Packet]):
    value = None
    for packet in packets:
        if packet.type == LITERAL_VALUE:
            return packet.value
        elif packet.type == SUM_OP:
            value = 0
            for sub_packet in packet.subpackets:
                value += evaluate_packets([sub_packet])
        elif packet.type == PROD_OP:
            value = 1
            for sub_packet in packet.subpackets:
                value *= evaluate_packets([sub_packet])
        elif packet.type == MIN_OP:
            value = float('inf')
            for sub_packet in packet.subpackets:
                value = min(value, evaluate_packets([sub_packet]))
        elif packet.type == MAX_OP:
            value = float('-inf')
            for sub_packet in packet.subpackets:
                value = max(value, evaluate_packets([sub_packet]))
        elif packet.type in [GT_OP, LT_OP, EQ_OP]:
            assert len(packet.subpackets) == 2
            sp1_val = evaluate_packets([packet.subpackets[0]])
            sp2_val = evaluate_packets([packet.subpackets[1]])
            if packet.type == GT_OP:
                value = 1 if sp1_val > sp2_val else 0
            elif packet.type == LT_OP:
                value =  1 if sp1_val < sp2_val else 0
            else:
                value = 1 if sp1_val == sp2_val else 0
        else:
            raise ValueError(f'Unrecognized packet type:', packet.type)

    return value


def test_parsers():
    texts = ["D2FE28", "38006F45291200"]
    versions = [6, 1]
    types = [4, 6]
    for text, gt_v, gt_t in zip(texts, versions, types):
        bitarray = hex2binarray(text)
        v, bitarray = strip_version(bitarray)
        t, bitarray = strip_type(bitarray)

        packet = Packet(v, t)

        assert gt_v == v
        assert gt_t == t
        if gt_t == LITERAL_VALUE:
            bitarray = strip_literal_value(bitarray, packet)
        else:
            bitarray = strip_operator(bitarray, packet)


def test():
    texts = ["8A004A801A8002F478", "620080001611562C8802118E34", "C0015000016115A2E0802F182340", "A0016C880162017C3686B18A3D4780"]
    version_sums = [16, 12, 23, 31]

    for text, gold_v_sum in zip(texts, version_sums):
        bitarray = hex2binarray(text)
        packets = parse_packets(bitarray)
        v_sum = count_versions(packets)
        assert v_sum == gold_v_sum, f'Expected {v_sum}, got {gold_v_sum}'
    
    texts = ["C200B40A82", "04005AC33890", "880086C3E88112", "CE00C43D881120", "D8005AC2A8F0", "F600BC2D8F", "9C005AC2F8F0", "9C0141080250320F1802104A08"]
    values = [3, 54, 7, 9, 1, 0, 0, 1]
    for text, gold_value in zip(texts, values):
        bitarray = hex2binarray(text)
        packets = parse_packets(bitarray)
        value = evaluate_packets(packets)
        assert value == gold_value


if __name__ == "__main__":
    test_parsers()

    test()
    text = read_input()
    bitarray = hex2binarray(text)
    packets = parse_packets(bitarray)
    print('VERSION COUNT:', count_versions(packets))
    print('EVALUATED PACKETS:', evaluate_packets(packets))
