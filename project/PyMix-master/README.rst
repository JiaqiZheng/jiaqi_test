pymix
=====

PyMix - The Python mixture package  

Author: Alexander Mendez 

Original Author: Benjamin Georgi <georgi@molgen.mpg.de>


Installation Instructions:
--------------------------

* Required Packages

    Python (version 2.5+ recommended, tested with 2.7)
    
    Numpy  (version 1.6?, tested with 1.6)
    
    GSL GNU Scientific library


* Optional Packages

    GHMM for mixtures of HMMs
    
    pylab for plotting functions in plotMixture.py

* How to install ?

    Extract the tarball to some directory of your choice. 
    Change into the directory and run:
    
        python setup.py build
        python setup.py install --prefix=/some/where
    
    If you wish to pull down the github version you can use pip:
    
        pip install git+https://github.com/ajmendez/PyMix.git
    
    It is now part of pypi:
        
        pip install pymix
    
    After the installation is completed I would recommend to run 
    mixtureunittests.py to check whether everything is in order.
    
    To get the GSL on OSX I recomend using homebrew to build the universal
    package so that it works with both the i386 version in EPD:
        
        brew install gsl --universal


Documentation:
--------------
    Example code for most aspects of the library can be found in 
    the pymix/examples subdirectory and mixtureunittest.py.
    Automatically generated documentation for the module is available 
    on the Pymix home page www.pymix.org.