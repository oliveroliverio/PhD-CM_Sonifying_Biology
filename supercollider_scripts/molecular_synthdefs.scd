// Molecular Music Sonification SynthDefs
// Load this file first to define the synthesis definitions

// Start the audio server
s.boot;

// Wait for server to boot
s.waitForBoot({
    
    // Core protein binding SynthDef
    SynthDef(\proteinBinding, { |out=0, kd=1000, kon=0.1, koff=0.05, 
                               structure=0, mw=50000, amp=0.3, dur=2|
        
        // Map binding affinity to frequency (log scale)
        var freq = kd.linexp(1, 10000, 80, 800);
        
        // Map kinetics to envelope
        var attack = kon.linexp(1000, 100000000, 0.01, 2);   // kon → attack time
        var release = koff.linexp(0.0001, 100, 0.1, 5);      // koff → release time
        
        // Map molecular weight to amplitude
        var dynAmp = mw.linlin(100, 1000, 0.1, 1.0) * amp;
        
        // Map structure to waveform
        var sig = SelectX.ar(structure, [
            SinOsc.ar(freq),           // α-helix (smooth)
            Saw.ar(freq) * 0.7,        // β-sheet (structured)
            WhiteNoise.ar * 0.3        // random coil (chaotic)
        ]);
        
        var env = Env.perc(attack, release, 1, -4).kr(doneAction:2);
        Out.ar(out, sig * env * dynAmp ! 2);
    }).add;

    // Cooperative binding SynthDef
    SynthDef(\cooperativeBinding, { |out=0, sites=4, kd1=100, kd2=50, 
                                   cooperativity=2, amp=0.2|
        var freqs = Array.fill(sites, { |i| 
            var effective_kd = kd1 * (kd2/kd1).pow(i * cooperativity);
            effective_kd.linexp(10, 1000, 200, 800);
        });
        
        var sig = Mix(freqs.collect({ |freq, i|
            var delay = i * 0.1; // Staggered binding
            var env = Env.perc(0.01, 1).kr(doneAction:0);
            DelayN.ar(SinOsc.ar(freq) * env, 1, delay);
        }));
        
        Out.ar(out, sig * amp ! 2);
    }).add;

    // Enzyme kinetics SynthDef  
    SynthDef(\enzymeKinetics, { |out=0, vmax=1, km=50, substrate=100, amp=0.3|
        // Michaelis-Menten equation: v = vmax * [S] / (km + [S])
        var velocity = vmax * substrate / (km + substrate);
        var freq = velocity.linlin(0, 1, 100, 400);
        var rate = velocity.linlin(0, 1, 0.5, 8); // Turnover rate
        
        var sig = SinOsc.ar(freq) * Env.perc(0.01, 1/rate).kr(doneAction:2);
        Out.ar(out, sig * amp ! 2);
    }).add;

    // Simple binding event SynthDef for single compounds
    SynthDef(\singleBinding, { |out=0, freq=440, amp=0.3, attack=0.1, release=1.0, 
                              waveform=0|
        var sig = SelectX.ar(waveform, [
            SinOsc.ar(freq),           // sine wave
            Saw.ar(freq) * 0.7,        // sawtooth
            WhiteNoise.ar * 0.3        // noise
        ]);
        
        var env = Env.perc(attack, release).kr(doneAction:2);
        Out.ar(out, sig * env * amp ! 2);
    }).add;

    "Molecular Music SynthDefs loaded successfully!".postln;
});
