using Printf

include("gen_rmesh_exp.jl")
include("lagrange_interp.jl")
include("radial_interp.jl")
include("rsch_integ_rk4.jl")
include("sch_rk4_step.jl")
include("get_min_idx.jl")
include("get_n_nodes.jl")

function main()
    # Build radial function
    r_min = 1e-9
    r_max = 50.0
    a = 1e9
    Nr = 1000
    rmesh = gen_rmesh_exp(r_min, r_max, a, Nr)

    Z = 1
    l = 0

    P = zeros(Float64,Nr)
    Q = zeros(Float64,Nr)
    V = -Z ./ rmesh

    E = -0.125
    imax = rsch_integ_rk4!( E, Z, l, rmesh, V, P, Q )
    println("imax = ", imax)

    println("Some P and Q")
    for i in 1:5
        @printf("%8d %20.10e %20.10e\n", i, P[i], Q[i])
    end
    @printf("...\n")
    for i in imax-5:imax
        @printf("%8d %20.10e %20.10e\n", i, P[i], Q[i])
    end

    minidx = get_min_idx(imax, P)
    println("minidx = ", minidx)
    println("imax   = ", imax)

    Nnodes = get_n_nodes( minidx-1, P )
    println("Nnodes = ", Nnodes)


    println("Pass here")
end

@time main()
@time main()
