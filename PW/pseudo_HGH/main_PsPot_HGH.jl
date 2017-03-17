include("PrintMatrix.jl")
include("PsPot_HGH.jl")

function test_main()
  #psp1 = PsPot_HGH(1, "H" , "LDA_HGH/1h.1.hgh")
  #psp2 = PsPot_HGH(2, "Ti", "LDA_HGH/22ti.12.hgh")
  #psp3 = PsPot_HGH(3, "Sm", "LDA_HGH/62sm.16.hgh")
  psp4 = PsPot_HGH(4, "Pt", "LDA_HGH/78pt.18.hgh")

  info_PsPot_HGH(psp4)

end

test_main()
