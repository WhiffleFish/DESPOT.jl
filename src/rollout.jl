function estimate_value(b, pomdp::POMDP, π0::Policy, d::Int)
    v = 0.0
    for s in b
        v += rollout(π0, pomdp, s, d)
    end
    return v
end

function rollout(π0::RandomRollout, pomdp::POMDP{S}, s::S, depth::Int) where S

    disc = 1.0
    r_total = 0.0
    rng = π0.rng
    step = 1

    while !isterminal(pomdp, s) && step <= depth

        a = action(π0, s)

        sp,r = @gen(:sp,:r)(pomdp, s, a, rng)

        r_total += disc*r

        s = sp

        disc *= discount(pomdp)
        step += 1
    end

    return r_total
end
