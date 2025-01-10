#include "DecayToSUEP.h"
#include "suep_shower.h"

// Uncomment the following line to enable debug messages to be printed to std::cout
//#define SUEP_DEBUG 1

namespace Pythia8 {

  //******************************
  //** Implementation of DecayToSUEP UserHook
  //******************************
  bool DecayToSUEP::doVetoProcessLevel(Event& process)
  {
#ifdef SUEP_DEBUG
    std::cout << "[SUEP_DEBUG] " << "Start of user hook for this event." << std::endl;
#endif

    //First, find the particle to decay
    bool particleFound=false;

#ifdef SUEP_DEBUG
    for (int ii=0; ii < process.size(); ++ii) {
      std::cout << "[SUEP_DEBUG] " << ii << ": id=" << process[ii].id() << ", Final=" << process[ii].isFinal() << ", Status=" << process[ii].status() << ", daughter1=" << process[ii].daughter1() << ", daughter2=" << process[ii].daughter2() << std::endl;
    }
#endif

    for (int ii=0; ii < process.size(); ++ii) {
      if ( (process[ii].id() == m_pdgId) and (process[ii].daughter1()!=process[ii].daughter2() && process[ii].daughter1()>0 && process[ii].daughter2()>0) ) {

	Vec4 higgs4mom, mesonmom;
	vector< Vec4 > suep_shower4momenta;	
	particleFound=true;

	//setup SUEP shower
	static Suep_shower suep_shower(m_darkMesonMass, m_darkTemperature, rndmPtr);

#ifdef SUEP_DEBUG
	std::cout << "[SUEP_DEBUG] " << "Particle (pdgId=" << m_pdgId << ", isFinal=True) found. Decaying to SUEP now." << std::endl;
#endif

	// First undo decay
	process[ii].undoDecay();

	int originalEventSize = process.size();

	// Generate the shower, output are 4 vectors in the rest frame of the shower
	higgs4mom=process[ii].p();
	suep_shower4momenta=suep_shower.generate_shower(higgs4mom.mCalc());
      
    // Veto event if less than 3 particles in the shower, skipt this event
    if( suep_shower4momenta.size()<3){
      std::cout << "Skipped event, insufficient particles in the shower or unsuccessful energy conservation\n";
      return true;
    }    

	// Loop over hidden sector mesons and append to the event	
	for (unsigned j = 0; j < suep_shower4momenta.size(); ++j){
	  //construct pythia 4vector
	  mesonmom = suep_shower4momenta[j];
            
	  // boost to the lab frame
	  mesonmom.bst(higgs4mom.px()/higgs4mom.e(),higgs4mom.py()/higgs4mom.e(), higgs4mom.pz()/higgs4mom.e());
            
	  //append particle to the event. Hidden/dark meson pdg code is 999999.
	  process.append(999999, 91, ii, 0, 0, 0, 0, 0, mesonmom.px(), mesonmom.py(), mesonmom.pz(), mesonmom.e(), m_darkMesonMass); 

#ifdef SUEP_DEBUG
	  std::cout << "[SUEP_DEBUG] " << "Adding dark meson with px=" << mesonmom.px() << ", py=" << mesonmom.py() << ", pz=" << mesonmom.pz() << ", m=" << m_darkMesonMass << std::endl;
#endif
	}

	// Just to be sure, only modify Higgs status and daughters if a valid decay did happen
	if ( suep_shower4momenta.size() > 0 ) {
#ifdef SUEP_DEBUG
	  std::cout << "[SUEP_DEBUG] " << "Setting original particle status-code as non-Final particle. Adding daughters with indices: " << originalEventSize << " - " << process.size()-1 << std::endl;
#endif
	  // Change the status code of the Higgs to reflect that it has decayed.
	  process[ii].statusNeg();
          
	  //set daughters of the Higgs. Take advantage that we just appended them
	  process[ii].daughters(originalEventSize, process.size()-1); 
	}
	
	//no need to continue the loop
	break;

      } // if particle to decay found

    } // loop over particles in the event

    if (not particleFound) {
      std::cout << "[DecayToSUEP] " << "Particle " << m_pdgId << " not found. Nothing to decay to SUEP for this event." << std::endl;
    } else {
#ifdef SUEP_DEBUG      
      std::cout << "[SEUP_DEBUG] " << "All Done for this event." << std::endl;
#endif
    }
#ifdef SUEP_DEBUG      
    std::cout << "[SUEP_DEBUG] Printing event after adding SUEP:" << std::endl;
    for (int ii=0; ii < process.size(); ++ii) {
      std::cout << "[SUEP_DEBUG] " << ii << ": id=" << process[ii].id() << ", Final=" << process[ii].isFinal() << ", mayDecay=" << process[ii].mayDecay() << ", Status=" << process[ii].status() << ", daughter1=" << process[ii].daughter1() << ", daughter2=" << process[ii].daughter2() << std::endl;
    }
#endif

    //return false: let the event continue
    return false;
  }


} // namespace Pythia8
