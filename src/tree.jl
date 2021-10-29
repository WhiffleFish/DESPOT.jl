function insert_belief(tree, b)
    push!(tree.b, b)
end

function Base.empty!(tree::DESPOTTree)
    empty!(tree.b)
    empty!(tree.b_children)
    empty!(tree.ba_children)
    empty!(tree.bao_children)
    empty!(v)
end

function insert_actions!(planner::DESPOTPlanner, b_idx::Int)
    tree = planner.tree
    A = planner.As
    L = length(tree.ba_children)
    for (i,a) in enumerate(A)
        push!(tree.b_children[b_idx], (a,L+i))
    end
end

function propagate!(planner::DESPOTPlanner, b_idx::Int, a, ba_idx::Int)
    tree = planner.tree
    pomdp = planner.pomdp
    L = length(tree.b)
    new_b_count = 1

    R = 0.0

    for s in tree.b[b_idx]
        sp, o, r = @gen(:sp, :o, :r)(pomdp, s, a)
        bp_idx = get(tree.bao_children, (ba_idx, o), nothing)
        R += r
        if !isnothing(bp_idx)
            push!(tree.b[bp_idx],sp)
        else
            bp_idx = L + new_b_count
            tree.bao_children[(ba_idx, o)] = bp_idx
            push!(tree.b, [sp])
            new_b_count += 1
        end
    end
    return R
end
