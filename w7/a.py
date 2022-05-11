a = []
extract = []
f = open("inside-the-mind-of-a-hacker-memory.bmp","rb")
data = f.read()

for i in range(54,54+720,3):
    a.append(data[i])
f.close()

for i in range(0,len(a),8):
    extract.append(''.join([str(x) for x in a[i:i+8]]))

def brute(a1):
    a = [0] * 8
    v11 = 0 
    for i in range(0x20, 0x7f):
        ii = bin(i) 
        aa = i
        a[v11] = aa & 1 
        a[v11 + 1] = (aa >> 1) & 1
        a[v11 + 2] = (aa >> 2) & 1
        a[v11 + 3] = (aa >> 3) & 1
        a[v11 + 4] = (aa >> 4) & 1
        a[v11 + 5] = (aa >> 5) & 1
        a[v11 + 6] = (aa >> 6) & 1
        a[v11 + 7] = (aa >> 7) & 1
        b = format(aa, '08b')
        c = a1
        if  b == c:
            #print(i)
            return i  

for i in extract:
    print(chr(brute(i[::-1])),end='')