export s_options, PG, FISTA, prox_split_1w, prox_split_2w


mutable struct s_params
	optTol
	maxIter
	verbose
	restart
	β
	λ
	η
    η_factor
    σ_TR
    WoptTol
    gk
    Bk
    xk

end


function s_options(β;optTol=1f-10, maxIter=10000, verbose=2, restart=10, λ=1.0, η =1.0, η_factor=.9,σ_TR=1.0,
     WoptTol=1f-10, gk = Vector{Float64}(undef,0), Bk = Array{Float64}(undef, 0,0), xk=Vector{Float64}(undef,0))

	return s_params(optTol, maxIter, verbose, restart, β,λ, η, η_factor,σ_TR, WoptTol, gk, Bk,xk)

end


#===========================================================================
	Proximal Gradient Descent for
	min_x ϕ(x) = f(x) + g(x), with f(x) cvx and β-smooth, g(x) closed cvx

	Input:
		x: initial point
		β: Lipschitz constant for F
		Fcn: function handle that returns f(x) and ∇f(x)
		proxG: function handle that calculates prox_{ηg}
		ε: tolerance, where ||x^{k+1} - x^k ||⩽ ε
		* max_iter: self-explanatory
		* print_freq: # of freq's in the sheets
	Output:
		x: x update
		flag 0: exit normal
		flag 1: max iter exit
===========================================================================#
function PG(Fcn, x,  proxG, options)
	ε=options.optTol
	max_iter=options.maxIter

	if options.verbose==0
		print_freq = Inf
	elseif options.verbose==1
		print_freq = round(max_iter/10)
	elseif options.verbose==2
		print_freq = round(max_iter/100)
	else
		print_freq = round(max_iter/200)
	end
	#Problem Initialize
	m = length(x)
	η = 1.0/options.β
	# λ = options.λ
	k = 1
	err = 100
	his = zeros(max_iter)


	# Iteration set up
	f, gradF = Fcn(x)
	feval = 1
	#do iterations
	while err ≥ ε && k <max_iter
		his[k] = f
		#take a gradient step: x-=η*∇f
		# BLAS.axpy!(-η, gradF, x1)
		#prox step
		xp = proxG(x - η*gradF)
		# update function info
		f, gradF = Fcn(xp)
		feval+=1
		err = norm(x-xp)
		x = xp
		k+=1
		#sheet on which to freq
		k % print_freq ==0 && @printf("Iter %4d, Obj Val %1.5e, ‖xᵏ⁺¹ - xᵏ‖ %1.5e\n", k, f, err)

	end
	# @printf("Error Criteria Reached! -> Obj Val %1.5e, ε = ‖xᵏ⁺¹ - xᵏ‖ %1.5e\n", f, err)
	return x, his[1:k-1], feval
end
#===========================================================================
	FISTA for
	min_x ϕ(x) = f(x) + g(x), with f(x) cvx and β-smooth, g(x) closed cvx

	Input:
		x: initial point
		β: Lipschitz constant for F
		Fcn!: function handle that returns f(x) and ∇f(x)
		proxG!: function handle that calculates prox_{ηg}
		ε: tolerance, where ||x^{k+1} - x^k ||⩽ ε
		* max_iter: self-explanatory
		* print_freq: # of freq's in the sheets
	Output:
		x: x update
===========================================================================#

function FISTA(Fcn, x,  proxG, options)
	ε=options.optTol
	max_iter=options.maxIter
	restart = options.restart
	η = options.β^(-1)
	# λ = options.λ
	if options.verbose==0
		print_freq = Inf
	elseif options.verbose==1
		print_freq = round(max_iter/10)
	elseif options.verbose==2
		print_freq = round(max_iter/100)
	else
		print_freq = round(max_iter/200)
	end

	#Problem Initialize
	m = length(x)
	y = zeros(m)


	#initialize parameters
	t = 1.0
	tk = t
	# Iteration set up
	k = 1
	err = 100.0
	his = zeros(max_iter)

	#do iterations
	f, gradF = Fcn(y)
	feval = 1
	while err >= ε && k<max_iter
		# if (mod(k, restart) == 1)
		# 		t = 1;
		# end

		his[k] = f
		xk = copy(x)
		x = proxG(y - η*gradF)

		#update x
		#		x = y - η*gradF;
		# BLAS.axpy!(-η, gradF, x)
		# x = proxG(y - η*gradF, η)

		#update step
		tk = t
		t = 0.5*(1.0 + sqrt(1.0+4.0*tk^2))

		#update y
		y = x + ((tk - 1.0)/t)*(x-xk)

		#check convergence
		err = norm(x - xk)


		#sheet on which to freq
		k % print_freq ==0 && @printf("Iter %4d, Obj Val %1.5e, ‖xᵏ⁺¹ - xᵏ‖ %1.5e\n", k, f, err)

		#update parameters
		f, gradF = Fcn(y)
		feval+=1
		k+=1
	end
	# f, _ = Fcn(y)
	# @printf("Error Criteria Reached! -> Obj Val %1.5e, ε = ‖xᵏ⁺¹ - xᵏ‖ %1.5e\n", f, err)
	return x, his[1:k-1], feval
end


function linesearch(x, zjl, zju, s, dzl, dzu,l,u ;mult=.9, tau = .01)
	α = 1.0
	     while(
            any(x + α*s - l .< (1-tau)*(x-l)) ||
            any(u - x - α*s .< (1-tau)*(u-x)) ||
            any(zjl + α*dzl .< (1-tau)*zjl) ||
            any(zju + α*dzu .< (1-tau)*zju)
            )
            α = α*mult

        end
        return α
end

function directsearch(x, zjl, zju, s, dzl, dzu; tau = .01) #used to be .01
	temp = [(-tau *(x-l))./s; (-tau*(u-x))./-s; (-tau*zjl)./dzl; (-tau*zju)./dzu]
    temp=filter((a) -> 1>=a>0, temp)
    # @printf("%1.5e | %1.5e | %1.5e | %1.5e \n", maximum(abs.((u - x)./s)), maximum(abs.((x-l)./s)), maximum(abs.(-zjl./dzl)), maximum(abs.(-zju./dzu)))
    temp = minimum(vcat(temp, 1.0))

	return temp


end
function directsearch!(xsl, usx,α, zjl, zju, s, dzl, dzu; tau = .01) #used to be .01
	temp = [(-tau *(xsl))./s; (-tau*(usx))./-s; (-tau*zjl)./dzl; (-tau*zju)./dzu]
    temp=filter((a) -> 1>=a>0, temp)
    α = minimum(vcat(temp, 1.0))
end

function  prox_split_1w(proxp, s0, projq, options)
    """Solves descent direction s for some objective function with the structure
        min_s q_k(s) + ψ(x+s) s.t. ||s||_q⩽ σ_TR
        for some σ_TR provided
    Arguments
    ----------
    proxp : prox method for p-norm
        takes in z (vector), a (λ||⋅||_p), p is norm for ψ I think
    s0 : Vector{Float64,1}
        Initial guess for the descent direction
    projq : generic that projects onto ||⋅||_q⩽σ_TR norm ball
    options : mutable structure p_params


    Returns
    -------
    s   : Vector{Float64,1}
        Final value of Algorithm 6.1 descent direction
    w   : Vector{Float64,1}
        relaxation variable of Algorithm 6.1 descent direction
    """
    ε=options.optTol
    max_iter=options.maxIter
    ε_w=options.WoptTol
    λ = options.λ
    σ_TR = options.σ_TR
    restart = options.restart
    #η_factor should have two values, as should η
    η = options.η
    ξ = options.β^(-1)
    η_factor = options.η_factor
    gk = options.gk
    Bk = options.Bk
    xk = options.xk

    if options.verbose==0
        print_freq = Inf
    elseif options.verbose==1
        print_freq = round(max_iter/10)
    elseif options.verbose==2
        print_freq = round(max_iter/100)
    else
        print_freq = 1
    end

    s = zeros(size(s0))
    u = s0+xk
    w = zeros(size(s0))

    err=100
    w_err = norm(w - xk - s)^2
    k = 1

    for i=1:restart
    while err>ε && k<max_iter && w_err>ε_w
        #store previous values
        s_ = s
        u_ = u
        w_ = w
        # prox(z,α) = prox_lp(z, α, q) #x is what is changed, z is what is put in, p is norm, a is ξ
        #I don't really like the Prox list that's currently in ProxLQ so I might make my own

        #u update with prox_(ξ*λ*||⋅||_p)(...)
        u = proxp(u_ - ξ*(gk +Bk*(u_ - xk) - (w_ - u_ + xk)/η), ξ*λ)

        #update s
        s = u - xk

        #w update
        w = projq(s, σ_TR)

        w_err = norm(w - xk-s)^2
        err = norm(s_ - s) + norm(w_ - w)
        k % print_freq ==0 && @printf("Iter: %4d, ||w-x-s||^2: %1.5e, s-err: %1.5e, w-err: %1.5e η: %1.5e, ξ: %1.5e \n", k, w_err, norm(s_ - s), norm(w_ - w), η, ξ)

        k = k+1
    end
            η *=η_factor
            err=100
            k=0
	end


    return s, w

end


function  prox_split_2w(proxp, s0, projq, options)
    """Solves descent direction s for some objective function with the structure
        min_s q_k(s) + ψ(x+s) s.t. ||s||_q⩽ σ_TR
        for some σ_TR provided
    Arguments
    ----------
    proxp : prox method for p-norm
        takes in z (vector), a (λ||⋅||_p), p is norm for ψ I think
    s0 : Vector{Float64,1}
        Initial guess for the descent direction
    projq : generic that projects onto ||⋅||_q⩽σ_TR norm ball
    options : mutable structure p_params


    Returns
    -------
    s   : Vector{Float64,1}
        Final value of Algorithm 6.2 descent direction
    w   : Vector{Float64,1}
        relaxation variable of Algorithm 6.2 descent direction
    """

    ε=options.optTol
    max_iter=options.maxIter
    ε_w=options.WoptTol
    λ = options.λ
    σ_TR = options.σ_TR
    restart = options.restart
    #η_factor should have two values, as should η
    η = options.η
    ξ = η
    η_factor = options.η_factor
    gk = options.gk
    Bk = options.Bk
    xk = options.xk

	print_freq = options.verbose

    u = s0+xk
    w1 = zeros(size(s0))
    w2 = zeros(size(s0))

    err=100
    w1_err = norm(w1 - u)^2
    w2_err = norm(w2 - u + xk)^2
	s_feas = norm(s0,1)-σ_TR
    k = 1
    b_pt1 = Bk*xk - gk

    for i=1:restart
    	A = Bk + (2/η)*I(size(Bk,1))
    while err>ε && k<max_iter #&& (w1_err+w2_err)>ε_w
        #store previous values
        u_ = u
        w1_ = w1
        w2_ = w2
        # prox(z,α) = prox_lp(z, α, q) #x is what is changed, z is what is put in, p is norm, a is ξ
        #I don't really like the Prox list that's currently in ProxLQ so I might make my own

        #u update with prox_(ξ*λ*||⋅||_p)(...)
        # u = cg(A, b_pt1 + (w2+xk+w1)/η; maxiter=5)
        u = fastcg(A,u_, b_pt1 + (w2+xk+w1)/η; maxiter=200)


        #update w1
        w1 = proxp(u, ξ*λ)

        #w2 update
        w2 = projq(u - xk, σ_TR)

        w1_err = norm(w1 - u)^2
        w2_err = norm(w2 - u + xk)^2
        err = norm(u_ - u) + norm(w1_ - w1) + norm(w2_ - w2)
        s_feas = norm(u-xk, 1)-σ_TR
        k % print_freq ==0 &&
        @printf("iter: %d, ||w1-u||²: %7.3e, ||w2-u+xk||²: %7.3e, err: %7.3e, η: %7.3e, s_feas: %7.3e \n", k, w1_err, w2_err, err, η, s_feas)

        k = k+1
    end
            η = η*η_factor
            ξ = η
            err=100
            k=1
    end


    return u - xk ,s_feas, err

end

function fastcg(A, x, b; epsilon=1f-5, maxiter=size(b,1))
	r = b - A*x
	p = r
	rsold = r'*r
	for i = 1:maxiter
	    Ap = A*p
	    alpha = rsold/(p'*Ap)
	    x = x+alpha*p
	    r = r-alpha*Ap
	    rsnew = r'*r
	    if sqrt(rsnew)<epsilon
	        break
	    end
	    p = r+(rsnew/rsold)*p
	    rsold = rsnew
	end
return x

end

function test_conv(x, Fcn, proxG,η, critin=1.0)
	m = length(x)
	gradF = zeros(m)
	xtest = copy(x)
	f, gradF = Fcn(xtest, gradF)
	BLAS.axpy!(-1.0, gradF, xtest)
	xtest = proxG(xtest, η)
	crit = norm(x - xtest)/critin

	return crit
end