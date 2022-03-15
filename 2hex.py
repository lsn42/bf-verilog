import os
file = "./data/echo.b"
out = "./data/hex"

fill_empty = True
size = 16

with open(file, "r") as f:
    data = f.read()

with open(os.path.join(out, (lambda x: x[:x.rfind(".")])(os.path.basename(file))+".hex"), "w") as f:
    count = 0
    data_hex = ""
    for i in data:
        data_hex += hex(ord(i))[2:]+" "
        count += 1
    data_hex += "ff"

    if fill_empty:
        data_hex += " 00"*(2**size-count-1)

    f.write(data_hex)

print("length: "+str(count))
