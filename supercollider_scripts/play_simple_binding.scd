// Play a simple binding event with mapped parameters
// Usage: sclang supercollider_scripts/play_simple_binding.scd <freq> <amp> <attack> <release> <waveform>

var args = thisProcess.argv;
var freq = if(args.size > 0, args[0].asFloat, 440);
var amp = if(args.size > 1, args[1].asFloat, 0.3);
var attack = if(args.size > 2, args[2].asFloat, 0.1);
var release = if(args.size > 3, args[3].asFloat, 1.0);
var waveform = if(args.size > 4, args[4].asInteger, 0);

// Start server if not running
if(s.serverRunning.not, {
    s.boot;
});

s.waitForBoot({
    // Load SynthDefs if not already loaded
    if(SynthDescLib.global.at(\singleBinding).isNil, {
        (thisProcess.nowExecutingPath.dirname +/+ "molecular_synthdefs.scd").load;
        1.wait;
    });
    
    ("Playing simple binding - Freq: " ++ freq ++ "Hz, Waveform: " ++ waveform).postln;
    
    Synth(\singleBinding, [
        \freq, freq,
        \amp, amp,
        \attack, attack,
        \release, release,
        \waveform, waveform
    ]);
});
