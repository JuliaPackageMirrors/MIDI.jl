validtestvalues = [
    # Structure: MTrk, length in bytes (4 bytes long), data
    # Perhaps longer than it needs to be, but covers meta events, MIDI events, and running statuses.
    (
        [0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x52, 0x60, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x3f, 0x00, 0x80, 0x40, 0x7f, 0x00, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x22, 0x00, 0x80, 0x40, 0x7f, 0x00, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x52, 0x00, 0x80, 0x40, 0x7f, 0x00, 0xff, 0x2f, 0x00],
        MIDI.MIDITrack(MIDI.TrackEvent[MIDI.MIDIEvent(96,0x90,UInt8[60,127]),MIDI.MIDIEvent(48,0x90,UInt8[67,127]),MIDI.MIDIEvent(48,0x80,UInt8[60,127]),MIDI.MIDIEvent(0,0x90,UInt8[64,127]),MIDI.MIDIEvent(48,0x80,UInt8[67,127]),MIDI.MIDIEvent(48,0xc0,UInt8[63]),MIDI.MIDIEvent(0,0x80,UInt8[64,127]),MIDI.MIDIEvent(0,0x90,UInt8[60,127]),MIDI.MIDIEvent(48,0x90,UInt8[67,127]),MIDI.MIDIEvent(48,0x80,UInt8[60,127]),MIDI.MIDIEvent(0,0x90,UInt8[64,127]),MIDI.MIDIEvent(48,0x80,UInt8[67,127]),MIDI.MIDIEvent(48,0xc0,UInt8[34]),MIDI.MIDIEvent(0,0x80,UInt8[64,127]),MIDI.MIDIEvent(0,0x90,UInt8[60,127]),MIDI.MIDIEvent(48,0x90,UInt8[67,127]),MIDI.MIDIEvent(48,0x80,UInt8[60,127]),MIDI.MIDIEvent(0,0x90,UInt8[64,127]),MIDI.MIDIEvent(48,0x80,UInt8[67,127]),MIDI.MIDIEvent(48,0xc0,UInt8[82]),MIDI.MIDIEvent(0,0x80,UInt8[64,127])])
    ),
]

invalidtestvalues = [
    ([0x00], EOFError),
    ([0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0xFF, 0x00], EOFError),
    ([0x4d, 0x54, 0x72, 0x6b], EOFError),
    ([0x4d, 0x54, 0x72, 0x6c], ErrorException),
]

for (input, output) in validtestvalues
    result = MIDI.readtrack(IOBuffer(input))
    @test length(result.events) == length(output.events)
    for (e1, e2) in zip(result.events, output.events)
        e1 == e2
    end
end

for (output, input) in validtestvalues
    buf = IOBuffer()
    MIDI.writetrack(buf, input)
    @test takebuf_array(buf) == output
end

for (input, errtype) in invalidtestvalues
    @test_throws errtype MIDI.readtrack(IOBuffer(input))
end

# Test writing notes and program change events to a track
C = MIDI.Note(60, 96, 0, 0)
G = MIDI.Note(67, 96, 48, 0)
E = MIDI.Note(64, 96, 96, 0)
inc = 96

track = MIDI.MIDITrack()
notes = MIDI.Note[]
for v in UInt8[1,2,3]
    push!(notes, C)
    push!(notes, E)
    push!(notes, G)
    MIDI.programchange(track, E.position + inc + inc, UInt8(0), v)
    C.position += inc
    E.position += inc
    G.position += inc
    C = MIDI.Note(60, 96, C.position+inc, 0)
    E = MIDI.Note(64, 96, E.position+inc, 0)
    G = MIDI.Note(67, 96, G.position+inc, 0)
end

MIDI.addnotes(track, notes)

buf = IOBuffer()
MIDI.writetrack(buf, track)
@test takebuf_array(buf) == [0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x52, 0x60, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x00, 0x00, 0x80, 0x40, 0x7f, 0x00, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x01, 0x00, 0x80, 0x40, 0x7f, 0x00, 0x90, 0x3c, 0x7f, 0x30, 0x43, 0x7f, 0x30, 0x80, 0x3c, 0x7f, 0x00, 0x90, 0x40, 0x7f, 0x30, 0x80, 0x43, 0x7f, 0x30, 0xc0, 0x02, 0x00, 0x80, 0x40, 0x7f, 0x00, 0xff, 0x2f, 0x00]

sort!(notes, lt=((x, y)->x.position<y.position))

# Test getting notes from a track
for (n1, n2) in zip(notes, MIDI.getnotes(track))
    @test n1 == n2
end
