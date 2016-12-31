"""
An implementation of simple method to calculate Ewald energy
"""
function calc_ewald( pw::PWGrid, Sf, Xpos, Nspecies::Int, atm2species,
                     Zv::Array{Float64}; sigma=nothing )
  #
  Npoints = pw.Npoints
  Ω  = pw.Ω
  r  = pw.r
  Ns = pw.Ns
  G2 = pw.G2
  LatVecs = pw.LatVecs
  #
  # Generate array of distances
  dr = gen_dr_center( r, LatVecs )
  #
  # Generate charge density
  #
  if sigma==nothing
    sigma = 0.25*ones(Nspecies)
  end
  #
  g1  = zeros( Float64, Npoints )
  rho_is = zeros( Float64, Npoints, Nspecies )
  Rho = zeros(Float64, Npoints)
  #
  for isp = 1:Nspecies
    c1 = 2*sigma[isp]^2
    cc1 = sqrt(2*pi*sigma[isp]^2)^3
    for ip=1:Npoints
      g1[ip] = exp(-dr[ip]^2/c1)/cc1
    end
    #
    g1 = Zv[isp] * g1[:]
    #
    ctmp = R_to_G( Ns, g1 )
    for ip = 1:Npoints
      ctmp[ip] = ctmp[ip]*Sf[ip,isp]
    end
    rho_is[:,isp] = real( G_to_R(Ns, ctmp) )
    intrho = sum(rho_is[:,isp])*Ω/Npoints
    @printf("Species %d, intrho: %18.10f\n", isp, intrho)
    Rho[:] = Rho[:] + rho_is[:,isp]
  end

  intrho = sum(Rho)*Ω/Npoints
  @printf("Integrated total Gaussian rho: %18.10f\n", intrho)

  #
  # Solve Poisson equation and calculate Hartree energy
  ctmp = 4.0*pi*R_to_G( Ns, Rho )
  ctmp[1] = 0.0
  for ip = 2:Npoints
    ctmp[ip] = ctmp[ip] / G2[ip]
  end
  phi = real( G_to_R( Ns, ctmp ) )
  Ehartree = 0.5*dot( phi, Rho ) * Ω/Npoints
  #
  Eself = 0.0
  Natoms = size(Xpos)[2]
  for ia = 1:Natoms
    isp = atm2species[ia]
    Eself = Eself + Zv[isp]/(2*sqrt(pi))*(1.0/sigma[isp])
  end
  E_nn = Ehartree - Eself
  @printf("Ehartree, Eself, E_nn = %20.16f %20.16f %20.16f\n", Ehartree, Eself, E_nn)
  return E_nn
end
