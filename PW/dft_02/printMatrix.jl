function printMatrix( A::Array{ComplexF64,2} )
    Nrows = size(A)[1]
    Ncols = size(A)[2]
    for ir = 1:Nrows
        for ic = 1:Ncols
            @printf("(%6.3f,%6.3f) ", real(A[ir,ic]), imag(A[ir,ic]))
        end
        @printf("\n")
    end
end

function printMatrix( A::Array{Float64,2} )
    Nrows = size(A)[1]
    Ncols = size(A)[2]
    for ir = 1:Nrows
        for ic = 1:Ncols
            @printf("%6.3f ", A[ir,ic])
        end
        @printf("\n")
    end
end