using OffsetArrays

mutable struct MagicMatrix{T,AA} <: AbstractMatrix{T}
    array::OffsetArray{T,2,AA}
    fill_value::T
end

MagicMatrix(x::T) where {T} = MagicMatrix(OffsetMatrix(fill(x, (0, 0)), 0, 0), x)

Base.size(m::MagicMatrix) = size(m.array)

Base.IndexStyle(::Type{<:MagicMatrix}) = IndexCartesian()

Base.getindex(m::MagicMatrix, i::Int, j::Int) = checkbounds(Bool, m.array, i, j) ? getindex(m.array, i, j) : m.fill_value

# Base.checkbounds(::Type{Bool}, ::MagicMatrix, i::Int) = true
Base.checkbounds(::Type{Bool}, ::MagicMatrix, i, j) = true
Base.checkbounds(::Type{Bool}, ::MagicMatrix, i, j, I...) = Base.checkbounds_indices(Bool, (), I)

Base.axes(m::MagicMatrix) = axes(m.array)
Base.axes(m::MagicMatrix, d) = axes(m.array, d)

function Base.setindex!(m::MagicMatrix, v, i::Int, j::Int)
    checkbounds(Bool, m.array, i, j) && return setindex!(m.array, v, i, j)
    old = m.array
    xr, yr = axes(old)

    new = OffsetMatrix{eltype(m)}(
        undef, min(i, first(xr)):max(i, last(xr)), min(j, first(yr)):max(j, last(yr))
    )
    new .= m.fill_value
    new[xr, yr] .= old
    m.array = new
    m[i, j] = v
end