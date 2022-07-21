import sys


fin = open(sys.argv[1], 'rb')
xorKey=int(sys.argv[2]);
fout = open(sys.argv[3], 'wb')

out = []

byte = fin.read(1)
print(type(byte))
while byte:
    oo = byte[0] ^ xorKey
    out.append(oo)
    byte = fin.read(1)
    
    
out = bytearray(out)

fout.write(out)
