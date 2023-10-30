#=========================================================================
# TapeOutBlockRTL Flow.py No Pad Ring
#=========================================================================
# Author : Jack Brzozowski
# Date   : May 16th, 2022
#

import os

from mflowgen.components import Graph, Step

def construct():

  g = Graph()

  this_dir = os.path.dirname( os.path.abspath( __file__ ) )

  #-----------------------------------------------------------------------
  # Parameters
  #-----------------------------------------------------------------------

  adk_name = 'freepdk-45nm'
  adk_view = 'stdview'

  parameters = {
    'construct_path'  : __file__,
    'sim_path'        : "{}/../../sim".format(this_dir),
    'design_path'     : "{}/../../sim/tapeout".format(this_dir),
    'design_name'     : 'grp_17_SPI_TapeOutBlockRTL_32bits_5entries', 
    'clock_period'    : 2.0,
    'clk_port'        : 'clk',
    'reset_port'      : 'reset',
    'adk'             : adk_name,
    'adk_view'        : adk_view,
    'pad_ring'        : False,

    # Block Gather
    "post_process"    : False,
    "template_name"   : "N/A",

    # VCS-sim
    'test_design_name': 'grp_17_SPI_TapeOutBlockRTL_32bits_5entries',
    'waveform'        : True,
    'input_delay'     : 0.05,
    'output_delay'    : 0.05,

    # Synthesis 
    'gate_clock'      : True,
    'high_effort_area_opt': False,
    'topographical'   : True,

    # # Hold Fixing 
    # 'hold_slack'      : 0.070,
    # 'setup_slack'     : 0.035,

    # PT Power
    'saif_instance'   : 'grp_17_SPI_TapeOutBlockRTL_32bits_5entries_tb/DUT',

    # Floorplan params
    'die_width'      : 960, # in um 
    'die_height'     : 1160,

  } 

  #-----------------------------------------------------------------------
  # Truncate design name at first instance of '__' to run the right tests
  #-----------------------------------------------------------------------
  
  trunc_design_name = parameters['design_name']
  trunc_design_name = trunc_design_name.split("__", 1)[0]
  parameters['trunc_design_name'] = trunc_design_name

  #-----------------------------------------------------------------------
  # Create nodes
  #-----------------------------------------------------------------------

  # ADK step

  g.set_adk( adk_name )
  adk = g.get_adk_step()

  # Custom steps

  info           = Step( 'info',                                     default=True )
  gather         = Step( 'brgtc5-block-gather',                      default=True )
  vcsSim         = Step( 'brg-synopsys-vcs-sim',                     default=True )
  synth          = Step( 'brg-synopsys-dc-synthesis',                default=True )
  init           = Step( 'brg-cadence-innovus-init',                 default=True )
  floorplan      = Step( 'brg-cadence-innovus-blocksetup-floorplan', default=True )
  powergrid      = Step( 'brg-cadence-innovus-blocksetup-power',     default=True )
  pnr            = Step( 'brg-cadence-innovus-pnr',                  default=True )
  signoff        = Step( 'brg-cadence-innovus-signoff',              default=True )
  sta            = Step( 'brg-synopsys-pt-sta',                      default=True )
  power          = Step( 'brg-synopsys-pt-power',                    default=True )
  summary        = Step( 'brg-flow-summary',                         default=True )

  # Clone vcsSim

  rtlsim     = vcsSim.clone()
  glFFsim    = vcsSim.clone()
  glBAsim    = vcsSim.clone()

  # Clone pt-power

  synthpower = power.clone()
  pnrpower   = power.clone()

  # Clone summary

  synthsummary=summary.clone()

  # Give clones new names

  rtlsim.set_name('brg-rtl-4-state-vcssim')
  glFFsim.set_name('post-synth-gate-level-simulation')
  glBAsim.set_name('post-pnr-gate-level-simulation')

  synthpower.set_name('post-synth-power-analysis')
  pnrpower.set_name("post-pnr-power-analysis")

  synthsummary.set_name('brg-synth-flow-summary')

  info.set_name('build-info')

  #-----------------------------------------------------------------------
  # Graph -- Add nodes
  #-----------------------------------------------------------------------

  g.add_step( info           )
  g.add_step( gather         )
  g.add_step( rtlsim         )
  g.add_step( synth          )
  g.add_step( glFFsim        ) 
  g.add_step( init           )
  g.add_step( floorplan      )
  g.add_step( powergrid      )
  g.add_step( pnr            )
  g.add_step( signoff        )
  g.add_step( sta            )
  g.add_step( glBAsim        ) 
  g.add_step( synthpower     )
  g.add_step( synthsummary   )
  g.add_step( pnrpower       )
  g.add_step( summary        )

  #-----------------------------------------------------------------------
  # Graph -- Add edges
  #-----------------------------------------------------------------------

  # Connect by name
  g.connect_by_name( adk,            rtlsim         )
  g.connect_by_name( adk,            synth          )
  g.connect_by_name( adk,            glFFsim        )
  g.connect_by_name( adk,            init           )
  g.connect_by_name( adk,            floorplan      )
  g.connect_by_name( adk,            powergrid      )
  g.connect_by_name( adk,            pnr            )
  g.connect_by_name( adk,            signoff        )
  g.connect_by_name( adk,            sta            )
  g.connect_by_name( adk,            glBAsim        )
  g.connect_by_name( adk,            synthpower     )
  g.connect_by_name( adk,            pnrpower       )

  g.connect_by_name( gather,         synth          )
  g.connect_by_name( gather,         rtlsim         )
  g.connect_by_name( gather,         glFFsim        )
  g.connect_by_name( gather,         glBAsim        )

  g.connect_by_name( synth,          glFFsim        ) # design.vcs.v
  g.connect_by_name( synth,          init           )
  g.connect_by_name( synth,          floorplan      )
  g.connect_by_name( synth,          powergrid      )
  g.connect_by_name( synth,          pnr            )
  g.connect_by_name( synth,          signoff        )  
  g.connect_by_name( synth,          synthsummary   )
  g.connect( synth.o( 'design.sdc'),   synthpower.i('design.sdc')) #design.sdc
  g.connect( synth.o( 'design.sdc'),   sta.i('design.sdc')) #design.sdc
  g.connect( synth.o( 'design.vcs.v'), synthpower.i('design.vcs.v')) #design.vcs.v
  g.connect( synth.o( 'design.spef.gz'), synthpower.i('design.spef.gz')) #design.spef.gz
  g.connect( synth.o( 'design.sdc'),     pnrpower.i('design.sdc')) #design.sdc

  g.connect_by_name( init,           floorplan      )
  g.connect_by_name( floorplan,      powergrid      )
  g.connect_by_name( powergrid,      pnr            )
  g.connect_by_name( pnr,            signoff        )

  # g.connect_by_name( signoff,        glBAsim        ) # design.vcs.v, design.sdf
  g.connect_by_name( signoff,        pnrpower       ) # design.vcs.v, design.spef.gz
  g.connect_by_name( signoff,        summary        )
  g.connect_by_name( signoff,        sta            ) # design.vcs.v, design.spef.gz
  g.connect( signoff.o( 'design.vcs.v'), glBAsim.i('design.vcs.v')) #design.vcs.v
  g.connect_by_name( sta,            glBAsim            ) # design.sdf

  g.connect_by_name( glFFsim,        synthpower     ) # saif, vcd
  g.connect_by_name( glBAsim,        pnrpower       ) # saif, vcd

  g.connect( rtlsim.o('sim.summary.txt'), synthsummary.i('4state.summary.txt'))
  g.connect( glFFsim.o('sim.summary.txt'), synthsummary.i('ff.summary.txt')) 
  g.connect( synthpower.o('power.summary.txt'), synthsummary.i('powerFF.summary.txt'))

  g.connect( rtlsim.o('sim.summary.txt'), summary.i('4state.summary.txt'))
  g.connect( glFFsim.o('sim.summary.txt'), summary.i('ff.summary.txt'))
  g.connect( glBAsim.o('sim.summary.txt'), summary.i('ba.summary.txt'))  
  g.connect( synthpower.o('power.summary.txt'), summary.i('powerFF.summary.txt'))
  g.connect( pnrpower.o('power.summary.txt'), summary.i('powerBA.summary.txt'))

  #-----------------------------------------------------------------------
  # Parameterize
  #-----------------------------------------------------------------------

  g.update_params( parameters )
  rtlsim.update_params({'simtype':'rtl'}, False)
  glFFsim.update_params({'simtype':'gate-level'}, False)
  glBAsim.update_params({'simtype': 'gate-level'}, False)
  synthpower.update_params({'zero_delay_simulation': True}, False)

  return g

if __name__ == '__main__':
  g = construct()

