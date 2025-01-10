// This is an example main pythia script to generate to generate a dark sector shower in a strongly coupled, quasi-conformal
// hidden valley, often referred to as "soft unclustered energy patterns (SUEP)" or "softbomb" events.
// The code for the dark shower itself is in suep_shower.cxx

// The algorithm relies on arXiv:1305.5226. See arXiv:1612.00850 for a description of the model. 
// Please cite both papers when using this code.

// Written by Simon Knapen on 12/22/2019

// pythia headers
// Standard headers
#include <iostream>
#include <cmath> // Prefer <cmath> over <math.h> in C++
#include <string>
#include <cstdio> // Prefer <cstdio> over <stdio.h> in C++
#include <cstdlib> // Prefer <cstdlib> over <stdlib.h> in C++

// Boost headers
#include <boost/math/tools/roots.hpp>
#include <boost/bind/bind.hpp> // Updated include
using namespace boost::placeholders; // Use the recommended namespace for placeholders

// Pythia headers
#include "Pythia8/Pythia.h"
#include "Pythia8Plugins/HepMC2.h"

// Your headers
#include "DecayToSUEP.h"

using namespace Pythia8;

template <typename T> string tostr(const T& t) { 
   ostringstream os; 
   os<<t; 
   return os.str(); 
} 

int main(int argc, char *argv[]) {
     
   // read model parameters from the command line
  if(!(argc==8)){
    std::cout << "I need the following arguments: M m T decaycard outputfilename randomseed\n";
    std::cout << "with\n";
    std::cout << "M: mass of heavy scalar\n";
    std::cout << "m: mass of dark mesons\n";
    std::cout << "T: Temperature parameter\n";
    std::cout << "decaycard: filename of the decay card\n";
    std::cout << "outputfilename: filename where events will be written\n";
    std::cout << "randomseed: an integer, specifying the random seed\n";
    std::cout << "NEvents: an integer, specifying the number of events generated\n";
    return 0;
  }
     

  // model parameters and settings
  float mh, mX,T;
  string seed, filename, cardfilename;    
  mh=atof(argv[1]);
  mX=atof(argv[2]);
  T=atof(argv[3]);
  cardfilename=tostr(argv[4]);
  filename=tostr(argv[5]);
  seed=tostr(argv[6]);
  int events= std::stoi(argv[7]);
  
  // number of events    
  int Nevents=events;    
    
  // Interface for conversion from Pythia8::Event to HepMC event.
  HepMC::Pythia8ToHepMC ToHepMC;

  // Specify file where HepMC events will be stored.
  HepMC::IO_GenEvent ascii_io(filename, std::ios::out);

  // pythia object
  Pythia pythia;
  
  //Settings for the Pythia object
  pythia.readString("Beams:eCM = 13000.");
  pythia.readString("HiggsSM:all = off"); //All SM major Higgs production modes
  pythia.readString("HiggsSM:ffbar2HZ = off");
  pythia.readString("HiggsSM:ffbar2HW = on");  
  pythia.readString("25:m0 = "+tostr(mh)); // set the mass of "Higgs" scalar
  pythia.readString("24:onMode = off");    // W⁺
  pythia.readString("-24:onMode = off");   // W⁻
  pythia.readString("24:onIfAny = 11 13 15");    // W⁺ → e⁺νₑ, μ⁺ν_μ, τ⁺ν_τ
  pythia.readString("-24:onIfAny = -11 -13 -15"); // W⁻ → e⁻ν̄ₑ, μ⁻ν̄_μ, τ⁻ν̄_τ
  pythia.readString("24:mMin = 0.1");    // W⁺
  pythia.readString("-24:mMin = 0.1");   // W⁻
  /*
  pythia.readString("25:0:onMode=1");
  pythia.readString("25:1:onMode=0");
  pythia.readString("25:2:onMode=0");
  pythia.readString("25:3:onMode=0");
  pythia.readString("25:4:onMode=0");
  pythia.readString("25:5:onMode=0");
  pythia.readString("25:6:onMode=0");
  pythia.readString("25:7:onMode=0");
  pythia.readString("25:8:onMode=0");
  pythia.readString("25:9:onMode=0");
  pythia.readString("25:10:onMode=0");
  pythia.readString("25:11:onMode=0");
  pythia.readString("25:12:onMode=0");
  pythia.readString("25:13:onMode=0");
  */
  pythia.readString("Random:setSeed = on");
  pythia.readString("Random:seed = "+seed); 
  pythia.readString("Next:numberShowEvent = 0");
  
  // for debugging / testing purposes only
  pythia.readString("PartonLevel:ISR = on");

  // To mimic CMSSW config
  pythia.readString("Tune:preferLHAPDF = 2"); 
  pythia.readString("Main:timesAllowErrors = 10000");
  pythia.readString("Check:epTolErr = 0.01");
  pythia.readString("Beams:setProductionScalesFromLHEF = off");
  pythia.readString("SLHA:minMassSM = 1000.");
  pythia.readString("ParticleDecays:limitTau0 = on");
  pythia.readString("ParticleDecays:tau0Max = 10");
  pythia.readString("ParticleDecays:allowPhotonRadiation = on");
  pythia.readString("Tune:pp 14");
  pythia.readString("Tune:ee 7");
  pythia.readString("MultipartonInteractions:ecmPow=0.03344");
  pythia.readString("MultipartonInteractions:bProfile=2");
  pythia.readString("MultipartonInteractions:pT0Ref=1.41");
  pythia.readString("MultipartonInteractions:coreRadius=0.7634");
  pythia.readString("MultipartonInteractions:coreFraction=0.63");
  pythia.readString("ColourReconnection:range=5.176");
  pythia.readString("SigmaTotal:zeroAXB=off");
  pythia.readString("SpaceShower:alphaSorder=2");
  pythia.readString("SpaceShower:alphaSvalue=0.118");
  pythia.readString("SigmaProcess:alphaSvalue=0.118");
  pythia.readString("SigmaProcess:alphaSorder=2");
  pythia.readString("MultipartonInteractions:alphaSvalue=0.118");
  pythia.readString("MultipartonInteractions:alphaSorder=2");
  pythia.readString("TimeShower:alphaSorder=2");
  pythia.readString("TimeShower:alphaSvalue=0.118");
  pythia.readString("SigmaTotal:mode = 0");
  pythia.readString("SigmaTotal:sigmaEl = 21.89");
  pythia.readString("SigmaTotal:sigmaTot = 100.309");
  pythia.readString("PDF:pSet=LHAPDF6:NNPDF31_nnlo_as_0118"); // Might be the issue with the docker image

  pythia.readString("UncertaintyBands:doVariations = on");
  pythia.readString("UncertaintyBands:List = {\
      isrRedHi isr:muRfac=0.707,fsrRedHi fsr:muRfac=0.707,isrRedLo isr:muRfac=1.414,fsrRedLo fsr:muRfac=1.414,\
      isrDefHi isr:muRfac=0.5,fsrDefHi fsr:muRfac=0.5,isrDefLo isr:muRfac=2.0,fsrDefLo fsr:muRfac=2.0,\
      isrConHi isr:muRfac=0.25,fsrConHi fsr:muRfac=0.25,isrConLo isr:muRfac=4.0,fsrConLo fsr:muRfac=4.0,\
      fsr_G2GG_muR_dn fsr:G2GG:muRfac=0.5,\
      fsr_G2GG_muR_up fsr:G2GG:muRfac=2.0,\
      fsr_G2QQ_muR_dn fsr:G2QQ:muRfac=0.5,\
      fsr_G2QQ_muR_up fsr:G2QQ:muRfac=2.0,\
      fsr_Q2QG_muR_dn fsr:Q2QG:muRfac=0.5,\
      fsr_Q2QG_muR_up fsr:Q2QG:muRfac=2.0,\
      fsr_X2XG_muR_dn fsr:X2XG:muRfac=0.5,\
      fsr_X2XG_muR_up fsr:X2XG:muRfac=2.0,\
      fsr_G2GG_cNS_dn fsr:G2GG:cNS=-2.0,\
      fsr_G2GG_cNS_up fsr:G2GG:cNS=2.0,\
      fsr_G2QQ_cNS_dn fsr:G2QQ:cNS=-2.0,\
      fsr_G2QQ_cNS_up fsr:G2QQ:cNS=2.0,\
      fsr_Q2QG_cNS_dn fsr:Q2QG:cNS=-2.0,\
      fsr_Q2QG_cNS_up fsr:Q2QG:cNS=2.0,\
      fsr_X2XG_cNS_dn fsr:X2XG:cNS=-2.0,\
      fsr_X2XG_cNS_up fsr:X2XG:cNS=2.0,\
      isr_G2GG_muR_dn isr:G2GG:muRfac=0.5,\
      isr_G2GG_muR_up isr:G2GG:muRfac=2.0,\
      isr_G2QQ_muR_dn isr:G2QQ:muRfac=0.5,\
      isr_G2QQ_muR_up isr:G2QQ:muRfac=2.0,\
      isr_Q2QG_muR_dn isr:Q2QG:muRfac=0.5,\
      isr_Q2QG_muR_up isr:Q2QG:muRfac=2.0,\
      isr_X2XG_muR_dn isr:X2XG:muRfac=0.5,\
      isr_X2XG_muR_up isr:X2XG:muRfac=2.0,\
      isr_G2GG_cNS_dn isr:G2GG:cNS=-2.0,\
      isr_G2GG_cNS_up isr:G2GG:cNS=2.0,\
      isr_G2QQ_cNS_dn isr:G2QQ:cNS=-2.0,\
      isr_G2QQ_cNS_up isr:G2QQ:cNS=2.0,\
      isr_Q2QG_cNS_dn isr:Q2QG:cNS=-2.0,\
      isr_Q2QG_cNS_up isr:Q2QG:cNS=2.0,\
      isr_X2XG_cNS_dn isr:X2XG:cNS=-2.0,\
      isr_X2XG_cNS_up isr:X2XG:cNS=2.0}");
    
  pythia.readString("UncertaintyBands:nFlavQ = 4pythia.readString"); // define X=bottom/top in X2XG variations
  pythia.readString("UncertaintyBands:MPIshowers = onpythia.readString");
  pythia.readString("UncertaintyBands:overSampleFSR = 10.0pythia.readString");
  pythia.readString("UncertaintyBands:overSampleISR = 10.0pythia.readString");
  pythia.readString("UncertaintyBands:FSRpTmin2Fac = 20pythia.readString");
  pythia.readString("UncertaintyBands:ISRpTmin2Fac = 20"); // for consistency with UL and P8.240 set to 20, to be optimized and changed for Run 3 re-MC  
  
  // define the dark meson
  pythia.readString("999999:all = GeneralResonance void 0 0 0 "+tostr(mX)+" 0.001 0.0 0.0 0.0");
  // this card had the dark photon branching ratios
  pythia.readFile(cardfilename);
  pythia.readString("Check:event = off");
  pythia.readString("Next:numberShowEvent = 0");
  std::shared_ptr<DecayToSUEP> suep_hook = std::make_shared<DecayToSUEP>();
  suep_hook->m_pdgId = 25;
  suep_hook->m_mass = mh;
  suep_hook->m_darkMesonMass = mX;
  suep_hook->m_darkTemperature = T;
  pythia.setUserHooksPtr(suep_hook);

  pythia.init();
  pythia.settings.listChanged();
   
  // Shortcuts
  Event& event = pythia.event;
  
  // Begin event loop. Generate event. Skip if error.
  int iEvent=0;
  while (iEvent < Nevents) {
    // Run the event generation
    if (!pythia.next()) {
      cout << " Event generation aborted prematurely, owing to error!\n";
      break;
    }
    
    // Print out a few events
    if (iEvent<1){  
        event.list();
    }
    
    // Construct new empty HepMC event and fill it.
    // Units will be as chosen for HepMC build; but can be changed
    // by arguments, e.g. GenEvt( HepMC::Units::GEV, HepMC::Units::MM)
    HepMC::GenEvent* hepmcevt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
    ToHepMC.fill_next_event( pythia, hepmcevt );

    // Write the HepMC event to file. Done with it.
    ascii_io << hepmcevt;
    delete hepmcevt;
    
    iEvent++;

  // End of event loop.
  }
  // print the cross sections etc    
  pythia.stat();

  // Done.
  return 0;
}
