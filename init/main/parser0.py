import re

def convert2(txt: str) -> str:
    k =  retf(txt, "")
    return k

def retf(txt_iter, ret_txt) -> str:
    if len(txt_iter) == 0:
        return ret_txt
    else:
        element = txt_iter[0]
        if element == '$':
            buf = ""
            for e in txt_iter:
                buf += e
                if e == '}':
                    break
            if inline_comment(buf):
                return retf(txt_iter[len(buf):], ret_txt + ' ')
            else:
                return retf(txt_iter[1:], ret_txt + element)

        else:
            return retf(txt_iter[1:], ret_txt + element)

def inline_comment(txt) -> bool:
    if len(txt) >= 6:
        pattern = re.compile("\$\{[0-9]+:.+\}")
        if pattern.match(txt):
            return True
        else:
            return False
    else:
        return False


if __name__ == "__main__":
    d0 = convert2("hoge${2: comment}huga")
    print(d0)

    d1 = convert2("hoge${2: comment}")
    print(d1)
    d2 = convert2("hoge${2: $")
    print(d2)
