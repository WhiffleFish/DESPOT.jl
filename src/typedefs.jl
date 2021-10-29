# TODO: include custom rollout policy
struct DESPOTTree{S,A,O}
    b::Vector{Vector{S}}
    b_children::Vector{Vector{Tuple{A,Int}}}
    ba_children::Vector{Vector{Int}} # ba_idx => [bp_idx, bp_idx, ...]
    bao_children::Dict{Tuple{Int,O}, Int} # (ba_idx,o) => bp_idx
    v::Vector{Float64}
    function DESPOTTree{S,A,O}()
        return new(
            Vector{S}[],
            Vector{Tuple{A,Int}}[],
            Vector{Int}[],
            Dict{Tuple{Int,O}, Int}(),
            Float64[]
        )
    end
end

@with_kw struct DESPOTSolver <: Solver
    K::Int = 10 # number of scenarios
    D::Int = 3 # search depth
    λ::Float64 = 0.1 # regularization factor
end

struct RandomRollout{RNG <: AbstractRNG, A} <: Policy
    rng::RNG
    a::A
end

RandomRollout(pomdp::POMDP) = RandomRollout(Random.MersenneTwister(rand(UInt64)), actions(pomdp))

POMDPs.action(ro::RandomRollout, ::Any) = rand(ro.rng, ro.a)

struct DESPOTPlanner{PP<:POMDP, SOL<:DESPOTSolver, ACT, TREE, P<:Policy} <: Policy
    pomdp::PP
    sol::SOL # solver
    A::ACT # action space
    tree::TREE
    π0::P
end

function POMDPs.solve(sol::DESPOTSolver, pomdp::POMDP)
    S = statetype(pomdp)
    A = actiontype(pomdp)
    O = obstype(pomdp)
    As = actions(pomdp)
    return DESPOTPlanner(
        pomdp,
        sol,
        As,
        DESPOTTree{S,A,O}(),
        RandomRollout(pomdp)
    )
end
