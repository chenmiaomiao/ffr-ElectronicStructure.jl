include("../common/ortho_gram_schmidt.jl")
include("../common/wrappers_fft.jl")
include("../common/gen_lattice_pwscf.jl")

include("gen_dr.jl")
include("init_pot_harm_3d.jl")
include("op_K.jl")
include("op_Vpot.jl")
include("op_H.jl")
include("calc_rho.jl")
include("calc_grad.jl")
include("calc_Etot.jl")
include("schsolve_Emin_sd.jl")
include("schsolve_Emin_cg.jl")
include("Kprec.jl")
include("diag_lobpcg.jl")
include("diag_davidson.jl")

function test_main( ; Ns_in=nothing, ecutwfc_Ry=nothing,
                   solution_method="diag_lobpcg" )

    LatVecs = gen_lattice_sc(6.0)

    if PWGRID_VERSION == 2
        if Ns_in != nothing
            pw = PWGrid( Ns_in, LatVecs )
        else
            @printf("PWGRID_VERSION 2 needs Ns_in\n")
            exit
        end
    elseif PWGRID_VERSION == 3
        if ecutwfc_Ry != nothing
            pw = PWGrid( 0.5*ecutwfc_Ry, LatVecs )
        else
            @printf("PWGRID_VERSION 3 needs ecutwfc_Ry\n")
            exit
        end
    else
        @printf("ERROR: Must specify Ns or ecutwfc_Ry")
        exit()
    end

    Ω  = pw.Ω
    r  = pw.r
    G  = pw.gvec.G
    G2 = pw.gvec.G2
    Ns = pw.Ns
    Npoints = prod(Ns)
    Ngwx = pw.gvecw.Ngwx

    @printf("Ns   = (%d,%d,%d)\n", Ns[1], Ns[2], Ns[3])
    @printf("Ngwx = %d\n", Ngwx)
    @printf("G2mx = %f\n", maximum(pw.gvec.G2[pw.gvecw.idx_gw2r]))

    if PWGRID_VERSION == 3
        @printf("ecutwfc_Ry = %f\n", ecutwfc_Ry)
    end

    actual = Npoints/Ngwx
    theor = 1/(4*pi*0.25^3/3)
    @printf("Compression: actual, theor: %f , %f\n", actual, theor)

    # Generate array of distances
    center = 6.0*ones(3)/2
    dr = gen_dr( r, center )

    # Setup potential
    Vpot = init_pot_harm_3d( pw, dr )
    println("sum(Vpot)*Ω/Npoints = ", sum(Vpot)*Ω/Npoints)

    Nstates = 4
    srand(2222)
    psi  = rand(ComplexF64,Ngwx,Nstates)
    psi = ortho_gram_schmidt(psi)

    if solution_method == "Emin"

        psi, Etot = schsolve_Emin_sd( pw, Vpot, psi, NiterMax=10 )
        psi, Etot = schsolve_Emin_cg( pw, Vpot, psi, NiterMax=1000 )

        Y = ortho_gram_schmidt(psi)
        mu = Y' * op_H( pw, Vpot, Y )
        evals, evecs = eigen(mu)
        Psi = Y*evecs

    else

        evals, psi = diag_lobpcg( pw, Vpot, psi, verbose=true, tol_avg=1e-10 )

    end

    # Davidson diagonalization is not working yet
    #evals, psi = diag_davidson( pw, Vpot, psi, verbose=true, tol_avg=1e-10 )

    for ist = 1:Nstates
        @printf("State # %d, Energy = %18.10f\n", ist, real(evals[ist]))
    end

end
