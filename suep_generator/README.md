README last updated by Simon Knapen on 08/09/2020 simon.knapen@cern.ch
Tested with Pythia 8.243 on a scientific Linux system (CentOS 5.5)
Software was written by Simon Knapen (CERN) and Simone Pagan Griso (LBL)

# Contains

- suep_shower.cxx, suep_shower.h: class containing the algorithm modeling the dark sector shower
- DecayToSUEP.cxx, DecayToSUEP.h: class handling the interface between suep_shower.cxx and pythia 8, by overloading the pythia 8's "doVetoProcessLevel" userhook
- main_suep.cc: example main script
- decay_example.cmnd, decay_darkphoton.cmnd, decay_darkphoton_hadronic.cmnd: examples of Pythia 8 cards with the settings for the decays of the dark mesons. The decay card should be provided by the user and depends on the model on is interested in.
- Makefile_example and Makefile_example.inc: example Makefiles (do not use for complication, see compilation instructions)
- README file

# Needs

- Pythia 8
- c++11
- boost library
- HEPMC2 (optional)

# Description

The suep_main.cc is an example script to generate events for strongly coupled, quasi-conformal hidden valleys (softbomb/SUEP). See hep-ph:1612.00850 for description of a of the model. The event generation happens in 3 stages:

(1) A scalar particle is produced through gluon fusion and subsequently decays to the hidden sector with 100% branching ratio. The mass of the scalar (M) can be specified by the user, where 125 GeV corresponds to the SM Higgs. This step is carried out by Pythia 8, which can also generate ISR if desired. At this time, no matching with Madgraph has been implemented.

(2) The shower is modeled by drawing momentum vectors for a single flavor of final state mesons with mass "m" from a relativistic Maxwell-Boltzman distribution with temperature "T". The parameters m and T must be set by the user. This step is carried out by the class contained in suep_shower.cxx.

(3) The final state mesons decay back to the Standard Model. This step is carried out by Pythia 8, including hadronization if needed. The branching ratios can be specified by the user in a decay card, which is supplied as an argument.

The output is provided in HEPMC2 format, though this can be changed to e.g. root by modifying both suep_main.cc and the Makefile. 

# Compilation instructions

0) Make sure you have a working copy of Pythia 8 as well as the boost libraries, with their paths configured. For example, the relevant lines in my own .bash_profile script are

PATH=$PATH:$HOME/bin:/share/apps/boost_1_58_0:/share/apps/HepMC2/x86_64-slc5-gcc41-opt/include
PATH=$PATH:~/.local/bin
export PATH
export PYTHIA8DATA=/home/smknapen/pythia8243_SUEP/share/Pythia8/xmldoc

Where "pythia8243_SUEP" is the top directory of the Pythia installation that I am using. 
When making use of the HEPMC2 output, make sure Pythia 8 is configured & compiled with HEPMC2.

1) create a new directory in the main Pythia 8 directory, e.g. "pythia8243/SUEP". Place all files in this tarball in this folder.

2) copy the Makefile and the Makefile.inc from the Pythia 8 "examples" folder to your SUEP folder. Add the following lines to this Makefile 


suep_main: $$@.cxx DecayToSUEP.cxx suep_shower.cxx\
        $(PREFIX_LIB)/libpythia8.a
ifeq ($(HEPMC2_USE),true)
        $(CXX) $^ -o $@ -I$(HEPMC2_INCLUDE) $(CXX_COMMON)\
         -L$(HEPMC2_LIB) -Wl,-rpath,$(HEPMC2_LIB) -lHepMC\
         $(GZIP_INC) $(GZIP_FLAGS)
else
        @echo "Error: $@ requires HEPMC2"
endif

(Beware about the usual trouble with tab's vs spaces in the Makefile.) The "Makefile_example" is my Makefile, and is included as an example only. I do not guarantee that using this file will work for your Pythia 8 installation. Better to use and modify the Makefile in the "examples" folder of your distribution, as described above.

3) make suep_main

4) ./suep_main

# Usage 

Run

./suep_main M m T decaycard outputfilename randomseed

e.g.

./main_suep 125.0 2.0 2.0 decay_example.cmnd test.hepmc 1

Where the floats M, m and T are the mass of the heavy scalar (e.g 125 for the Higgs), the mass of the hidden sector mesons and the temperature respectively. outputfilename is the name and path of file in which the events will be written. randomseed should be an integer, and is the seed of Pythia's random number generator. Non-identical runs must have different random seeds.

The branching ratios of the dark mesons can be specified by modifying the "decay_example.cmnd". 

IMPORTANT:
Please check that your choice for the decays is kinematically compatible with your choice for m! At this time, the code does not check for this, and if no decay channels are available, pythia will simply not decay the dark mesons.

This manner of providing the model parameters can of course be changed by modifying the relevant part of the main_suep.cc script.

# Warnings, regime of validity and known issues

- The ratio of the parameters m and T (m/T) should be an O(1) number. For m/T>>1 and m/T<<1 the theoretical description of the shower is likely not valid. 

- The mass of the scalar which initials the shower should be much larger than the mass of the mesons, in other words M>>m,T, by at least an order of magnitude. If the shower generates less than 3 events, the event will be veto-ed and a warning message is printed. This means that if you where to choose M/m or M/T to be insufficiently large, the event generation may become extremely slow, as it struggles to find events with suffiently high multiplicity. This is a sign that you are using the monte carlo outside the regime of its validity.  

- In the current beta-version there are small numerical errors which imply that energy and momentum may not be exactly conserved in some events. The discrepancy is however too small to be experimentally relevant, but may derail certain routines which compulsively check for energy and momentum conservation. In particular, at the moment some of Pythia's internal checks are overruled when decaying the dark mesons.

# Thanks

- Thanks to Kevin Pedro for suggesting the userhook method and for providing a working example.
- Thanks to Cari Cessarotti, Alexander Lory and Elena Villhauer for beta-testing and useful feedback.


