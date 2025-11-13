// Play a single protein binding event
// Usage: sclang supercollider_scripts/play_binding_event.scd <kd> <kon> <koff> <structure> <mw> <amp>

// Get command line arguments
var args = thisProcess.argv;
var kd = if(args.size > 0, args[0].asFloat, 1000);
var kon = if(args.size > 1, args[1].asFloat, 100000);
var koff = if(args.size > 2, args[2].asFloat, 0.1);
var structure = if(args.size > 3, args[3].asInteger, 0);
var mw = if(args.size > 4, args[4].asFloat, 400);
var amp = if(args.size > 5, args[5].asFloat, 0.3);

// Start server if not running
if(s.serverRunning.not, {
    s.boot;
});

s.waitForBoot({
    // Load SynthDefs if not already loaded
    if(SynthDescLib.global.at(\proteinBinding).isNil, {
        ("Loading SynthDefs from: " ++ thisProcess.nowExecutingPath.dirname +/+ "molecular_synthdefs.scd").postln;
        (thisProcess.nowExecutingPath.dirname +/+ "molecular_synthdefs.scd").load;
        1.wait; // Wait for SynthDefs to load
    });
    
    // Play the binding event
    ("Playing binding event - Kd: " ++ kd ++ "nM, Structure: " ++ structure).postln;
    
    Synth(\proteinBinding, [
        \kd, kd, 
        \kon, kon, 
        \koff, koff, 
        \structure, structure, 
        \mw, mw, 
        \amp, amp
    ]);
});
