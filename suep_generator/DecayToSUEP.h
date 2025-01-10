#include "Pythia8/Pythia.h"
#include "boost/lexical_cast.hpp"
#include "boost/bind.hpp"
#include <boost/math/tools/roots.hpp>
#include <math.h>
#include <stdexcept>
#include <iostream>

namespace Pythia8{

  //******************************
  //** Main UserHook derived class
  //******************************

  /** Pythia8 UserHook to decay a given scalar particle to SUEP. 
   *
   * Details on models available on arXiv:1612.00850.
   * This is an adaption from the available public code at: 
   * https://gitlab.com/simonknapen/suep_generator 
   * by Simon Knapen.
   *
   */
  class DecayToSUEP : public UserHooks{
    
  public:
    
    DecayToSUEP(): 
      m_pdgId(25), 
      m_mass(125.0),
      m_darkMesonMass(1.), 
      m_darkTemperature(1.) {
	
      std::cout<<"**********************************************************"<<std::endl;
      std::cout<<"*                                                        *"<<std::endl;
      std::cout<<"*             Enabled SUEP decay UserHook!               *"<<std::endl;
      std::cout<<"*                                                        *"<<std::endl;
      std::cout<<"**********************************************************"<<std::endl;
      
    }
    
    ~DecayToSUEP(){}

    // Enable the call to the user-hook
    virtual bool canVetoProcessLevel() {
      return true;
    }

    /* Actually implement the user hook.
     *
     * We slightly abuse this function in the sense that no veto is performed but instead
     * the hook is used to modify the event record in between the process-level and parton-level steps.
     * This modification is allowed in the Pythia8 manual, with warning of event consistency that
     * should pose no harm in this context.
     */
    virtual bool doVetoProcessLevel(Event& process);


  public:

    /** PDG Id of particle to be decayed to SUEP */
    //Pythia8_UserHooks::UserSetting<int> m_pdgId;
    int m_pdgId;

    /** Mass of system decaying [GeV] */
    double m_mass;

    /** Dark-meson mass parameter [GeV] */
    double m_darkMesonMass;

    /** Temperature parameter [GeV] */
    double m_darkTemperature;

  };

}
