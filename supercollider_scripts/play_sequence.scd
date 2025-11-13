// Play a sequence of binding events from a CSV file
// Usage: sclang supercollider_scripts/play_sequence.scd <csv_file> <delay_between_events>

var args = thisProcess.argv;
var csvFile = if(args.size > 0, args[0], "binding_sequence.csv");
var delay = if(args.size > 1, args[1].asFloat, 0.5);

// Start server if not running
if(s.serverRunning.not, {
    s.boot;
});

s.waitForBoot({
    // Load SynthDefs
    if(SynthDescLib.global.at(\singleBinding).isNil, {
        (thisProcess.nowExecutingPath.dirname +/+ "molecular_synthdefs.scd").load;
        2.wait;
    });
    
    // Read CSV file
    var file = File(csvFile, "r");
    var lines, data;
    
    if(file.isOpen, {
        lines = file.readAllString.split($\n);
        file.close;
        
        // Skip header line
        lines = lines[1..];
        
        ("Playing sequence from: " ++ csvFile).postln;
        ("Number of events: " ++ lines.size).postln;
        
        // Parse and play each line
        lines.do({ |line, i|
            if(line.size > 0, {
                var values = line.split($,);
                var freq = values[0].asFloat;
                var amp = values[1].asFloat;
                var attack = values[2].asFloat;
                var release = values[3].asFloat;
                var waveform = values[4].asInteger;
                
                // Schedule the synth
                SystemClock.sched(i * delay, {
                    ("Event " ++ (i+1) ++ ": freq=" ++ freq ++ "Hz").postln;
                    Synth(\singleBinding, [
                        \freq, freq,
                        \amp, amp,
                        \attack, attack,
                        \release, release,
                        \waveform, waveform
                    ]);
                });
            });
        });
    }, {
        ("Could not open file: " ++ csvFile).postln;
    });
});
