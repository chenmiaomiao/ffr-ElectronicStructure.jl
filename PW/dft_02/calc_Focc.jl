# spin-unpolarized version
function calc_Focc(evals, Nelectrons, kT::Float64; is_spinpol=false)

    Nstates = length(evals)
    const TOL = 1e-10
    const MAXITER = 100

    Focc = zeros(Nstates)
    Nocc = round(Int64,Nelectrons/2)  # normally
    @printf("Nelectrons = %d\n", Nelectrons)
    @printf("Nocc = %d\n", Nocc)

    # use bisection to find E_fermi such that 
    #  sum_i Focc(i) = Nelectrons
    if Nstates > Nocc
        ilb = Nocc - 1
        iub = Nocc + 1
        # FIXME: Need to guard against the case Nocc == 1
        lb = evals[ilb]
        ub = evals[iub]
        # make sure flb < Nelectrons and fub > Nelectrons
        # Use lb and ub as guess interval for searching Fermi energy
        Focc_lb = smear_FD(evals, lb, kT, is_spinpol=is_spinpol)
        Focc_ub = smear_FD(evals, ub, kT, is_spinpol=is_spinpol)
        flb = sum(Focc_lb)
        fub = sum(Focc_ub)
        while ( (Nelectrons-flb)*(fub-Nelectrons) < 0 )
            @printf("calc_Focc: initial bounds are off:\n");
            @printf("flb = %18.10f, fub = %18.10f, Nelectrons = %d\n", flb, fub, Nelectrons)
            if (flb > Nelectrons)
                if (ilb > 1)
                    ilb = ilb - 1
                    lb = evals[ilb]
                    Focc = smear_FD(evals, lb, kT, is_spinpol=is_spinpol)
                    flb = sum(Focc)
                else
                    @printf("ERROR in calc_Focc: cannot find a lower bound for E_fermi\n")
                    exit()
                end
            end
            #
            if (fub < Nelectrons)
                if (iub < Nstates)
                    iub = iub + 1
                    ub  = evals[iub]
                    Focc = smear_FD(evals, ub, kT, is_spinpol=is_spinpol)
                    fub = sum(Focc)
                else
                    @printf("ERROR in calc_Focc: cannot find an upper bound for E_fermi\n")
                    @printf("Try increasing the number of states\n")
                    exit()
                end
            end
        end  # while
        
        @printf("\nInitial bounds are OK: flb = %18.10f, fub = %18.10f\n", flb, fub)
        
        E_fermi = (lb + ub)/2
        Focc = smear_FD(evals, E_fermi, kT, is_spinpol=is_spinpol)
        occsum = sum(Focc)
        
        for iter = 1:MAXITER
            diffNelec = abs(occsum-Nelectrons)
            if diffNelec < TOL
                @printf("Found E_fermi = %18.10f, occsum = %18.10f\n", E_fermi, occsum )
                return Focc, E_fermi
            end
            @printf("%3d %18.10f %18.10f %18.10e\n", iter, E_fermi, occsum, diffNelec)
            if (occsum < Nelectrons)
                lb = E_fermi
            else
                ub = E_fermi
            end
            E_fermi = (lb + ub)/2
            Focc = smear_FD(evals, E_fermi, kT, is_spinpol=is_spinpol)
            occsum = sum(Focc)
        end #
        @printf("WARNING: Maximum iteration achieved, E_fermi is not found within specified tolarance\n")
        return Focc, E_fermi
    
    # 
    elseif (Nstates == Nocc)
        @printf("Nstates is equal to Nocc\n")
        if is_spinpol
            Focc = 2.0*ones(Nstates)
            E_fermi = evals[Nstates]
        else
            Focc    = ones(Nstates)
            E_fermi = evals[Nstates]
        end
        return Focc, E_fermi
    
    else
        @printf("ERROR: The number of eigenvalues in evals should be larger than Nelectrons")
        exit()
    end

end
