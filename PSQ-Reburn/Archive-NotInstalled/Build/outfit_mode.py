"""Select the existing synchronous wardrobe branches at install time.

One assignment replaces one call. Saved instruction positions, script fields,
function signatures and event names stay identical across both editions.
"""
import struct
from collections import Counter
from assets import parse, functions, decode

EFFECT = 'succubusheshinnscript'
QUEST = 'playersuccubusquestscript'
SCRIPTS = tuple('scripts/' + name + '.pex' for name in (EFFECT, QUEST))
WARDROBE = frozenset("""
begintransformafterload beginappearanceedit isappearanceoperationcurrent
isequipmentrecoverycurrent applyentryoutfitselection28 applysuccubusoutfitselectioncore40
saveentryoutfitsnapshot striptransformaccessories equiptransformpartsphase equipresolvedentrypart
buildequipmentswapplan28 buildequipmentswapplanlegacy29 isequipmentswapplancurrent
publishoutfitplan29 clearequipmentswapplan restoretransformequipment
releaseledgeritemforload cleanuptransformledgerforload restoreoriginalwithreceipt
clearrestoredequipmentfields commitpendingoriginalequipment isoriginalequipmentrequestcurrent
queuependingoriginalequipmentrecovery releaseoriginalequipmentrequest onpendingoriginalequipmentrecovery
retrypendingoriginalequipment runnativeequipmentrestore runnativeequipmentrestore27
tryrecoverinterruptedappearance changeoutfitpartfrommenu40
""".split())
HIDE = {'striptransformaccessories', 'buildequipmentswapplanlegacy29', 'applyoriginalequipmentvisibility'}

def legacy(blob, script):
    parsed = parse(blob)
    obj, = parsed['objects']
    edits, seen = [], Counter()
    for (_, method), func in functions(parsed).items():
        *_, start, ops = decode(parsed, func)
        offset = start + 2
        for op, args, raw in ops:
            value = None
            if (script == EFFECT or method in WARDROBE) and op == 'static':
                if [v.lower() for _, v in args[:2]] == ['skse','getpluginversion'] and args[3:] == [(2,'PSQ Appearance')]:
                    value = b'\x03' + struct.pack('>i', -1)
            if script == QUEST and method in HIDE and op == 'method' and args[0][1].lower() == 'getoriginalequipmenthideenabled':
                value = b'\x05\x00'
            if script == QUEST and method == 'endappearanceedit' and op == 'static' and [v.lower() for _,v in args[:2]] == ['psqvis50','available']:
                value = b'\x05\x00'
            if value is not None:
                assert args[2][0] == 1 and raw[7] == 1
                edits.append((offset, offset+len(raw), b'\x0d' + raw[7:10] + value))
                seen[method] += 1
            offset += len(raw)
    assert seen and (script == EFFECT or WARDROBE | HIDE | {'endappearanceedit'} <= seen.keys()), (script, WARDROBE-seen.keys())
    result = bytearray(blob)
    for start, end, new in sorted(edits, reverse=True):
        result[start:end] = new
    pos = obj['sizepos']
    fmt = obj['size_endian'] + 'I'
    size, = struct.unpack_from(fmt, blob, pos)
    struct.pack_into(fmt, result, pos, size + len(result)-len(blob))
    return bytes(result)
