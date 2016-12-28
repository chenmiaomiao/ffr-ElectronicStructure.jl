function G_to_R( Ns::Array{Int,1}, fG::Array{Complex128,1} )
  out = reshape( ifft( reshape(fG,Ns[1],Ns[2],Ns[3]) ),
        size(fG) )
end

function G_to_R( Ns::Array{Int,1}, fG::Array{Complex128,2} )
  Npoints = prod(Ns)
  out = zeros( Complex128, size(fG) ) # Is this safe?
  for ic = 1:size(fG,2)
    out[:,ic] = reshape( ifft( reshape(fG[:,ic],Ns[1],Ns[2],Ns[3]) ), Npoints )
  end
  return out
end

# --- Call FFTW3 directly --- #

function c_G_to_R( Ns::Array{Int,1}, fG::Array{Complex128,1} )
  out = zeros(Complex128,Ns[1]*Ns[2]*Ns[3])
  ccall( (:fftw_inv_fft3d, "../libs/fft3d.so"), Void,
    (Ptr{Complex128}, Ptr{Complex128}, Int64, Int64, Int64), fG, out,
    Ns[3],Ns[2],Ns[1] )
  return out
end

"""
Multicolumn version
"""
function c_G_to_R( Ns::Array{Int,1}, fG::Array{Complex128,2} )
  Npoints = size(fG)[1]
  Ncol = size(fG)[2]
  out = zeros(Complex128,Npoints,Ncol)
  for ic = 1:Ncol
    ccall( (:fftw_inv_fft3d, "../libs/fft3d.so"), Void,
        (Ptr{Complex128}, Ptr{Complex128}, Int64, Int64, Int64), fG[:,ic], out[:,ic],
        Ns[3],Ns[2],Ns[1] )
  end
  return out
end
function R_to_G( Ns::Array{Int,1}, fR::Array{Complex128,1} )
  out = reshape( fft( reshape(fR,Ns[1],Ns[2],Ns[3]) ), size(fR) )
end

# In case we forget to convert the input, we convert it in this version
function R_to_G( Ns::Array{Int,1}, fR_::Array{Float64,1} )
  fR = convert(Array{Complex128,1},fR_)
  out = reshape( fft( reshape(fR,Ns[1],Ns[2],Ns[3]) ), size(fR) )
end

function R_to_G( Ns::Array{Int,1}, fR::Array{Complex128,2} )
  Npoints = prod(Ns)
  Ncol = size(fR,2)
  out = zeros( Complex128, size(fR) )
  for ic = 1:Ncol
    out[:,ic] = reshape( fft( reshape(fR[:,ic],Ns[1],Ns[2],Ns[3]) ), Npoints )
  end
  return out
end

# --- Call FFTW3 directly --- #

function c_R_to_G( Ns::Array{Int,1}, fR::Array{Complex128,1} )
  out = zeros(Complex128,Ns[1]*Ns[2]*Ns[3])
  ccall( (:fftw_fw_fft3d, "../libs/fft3d.so"), Void,
    (Ptr{Complex128}, Ptr{Complex128}, Int64, Int64, Int64), fR, out,
    Ns[3],Ns[2],Ns[1] )
  return out
end

"""
Multicolumn version
"""
function c_R_to_G( Ns::Array{Int,1}, fR::Array{Complex128,2} )
  Npoints = size(fR)[1]
  Ncol = size(fR)[2]
  out = zeros(Complex128,Npoints,Ncol)
  for ic = 1:Ncol
    ccall( (:fftw_fw_fft3d, "../libs/fft3d.so"), Void,
        (Ptr{Complex128}, Ptr{Complex128}, Int64, Int64, Int64), fR[:,ic], out[:,ic],
        Ns[3],Ns[2],Ns[1] )
  end
  return out
end
