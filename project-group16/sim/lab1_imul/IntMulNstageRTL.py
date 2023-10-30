#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultNstagePRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulNstageVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

from .IntMulMsgs import IntMulMsgs

class IntMulNstageVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nstages=2 ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'IntMulNstageRTL__nstages_{nstages}' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( IntMulMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( IntMulMsgs.resp )

# See if the course staff want to force testing a specific RTL language
# for their own testing.

import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .IntMulNstagePRTL import IntMulNstagePRTL as IntMulNstageRTL
elif rtl_language == 'verilog':
  IntMulNstageRTL = IntMulNstageVRTL
else:
  raise Exception("Invalid RTL language!")
