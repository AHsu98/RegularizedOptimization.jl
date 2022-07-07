var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [RegularizedOptimization]","category":"page"},{"location":"reference/#RegularizedOptimization.FISTA-Tuple{NLPModels.AbstractNLPModel, Vararg{Any}}","page":"Reference","title":"RegularizedOptimization.FISTA","text":"FISTA for   min_x ϕ(x) = f(x) + g(x), with f(x) cvx and β-smooth, g(x) closed cvx\n\nInput:     f: function handle that returns f(x) and ∇f(x)     h: function handle that returns g(x)     s: initial point     proxG: function handle that calculates prox_{νg}     options: see descentopts.jl   Output:     s⁺: s update     s : s^(k-1)     his : function history     feval : number of function evals (total objective)\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.LM-Union{Tuple{H}, Tuple{NLPModels.AbstractNLSModel, H, ROSolverOptions}} where H","page":"Reference","title":"RegularizedOptimization.LM","text":"LM(nls, h, options; kwargs...)\n\nA Levenberg-Marquardt method for the problem\n\nmin ½ ‖F(x)‖² + h(x)\n\nwhere F: ℝⁿ → ℝᵐ and its Jacobian J are Lipschitz continuous and h: ℝⁿ → ℝ is lower semi-continuous, proper and prox-bounded.\n\nAt each iteration, a step s is computed as an approximate solution of\n\nmin  ½ ‖J(x) s + F(x)‖² + ½ σ ‖s‖² + ψ(s; x)\n\nwhere F(x) and J(x) are the residual and its Jacobian at x, respectively, ψ(s; x) = h(x + s), and σ > 0 is a regularization parameter.\n\nArguments\n\nnls::AbstractNLSModel: a smooth nonlinear least-squares problem\nh: a regularizer such as those defined in ProximalOperators\noptions::ROSolverOptions: a structure containing algorithmic parameters\n\nKeyword arguments\n\nx0::AbstractVector: an initial guess (default: nls.meta.x0)\nsubsolver_logger::AbstractLogger: a logger to pass to the subproblem solver\nsubsolver: the procedure used to compute a step (PG or R2)\nsubsolver_options::ROSolverOptions: default options to pass to the subsolver.\n\nReturn values\n\nxk: the final iterate\nFobj_hist: an array with the history of values of the smooth objective\nHobj_hist: an array with the history of values of the nonsmooth objective\nComplex_hist: an array with the history of number of inner iterations.\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.LMTR-Union{Tuple{X}, Tuple{H}, Tuple{NLPModels.AbstractNLSModel, H, X, ROSolverOptions}} where {H, X}","page":"Reference","title":"RegularizedOptimization.LMTR","text":"LMTR(nls, h, χ, options; kwargs...)\n\nA trust-region Levenberg-Marquardt method for the problem\n\nmin ½ ‖F(x)‖² + h(x)\n\nwhere F: ℝⁿ → ℝᵐ and its Jacobian J are Lipschitz continuous and h: ℝⁿ → ℝ is lower semi-continuous and proper.\n\nAt each iteration, a step s is computed as an approximate solution of\n\nmin  ½ ‖J(x) s + F(x)‖₂² + ψ(s; x)  subject to  ‖s‖ ≤ Δ\n\nwhere F(x) and J(x) are the residual and its Jacobian at x, respectively, ψ(s; x) = h(x + s), ‖⋅‖ is a user-defined norm and Δ > 0 is a trust-region radius.\n\nArguments\n\nnls::AbstractNLSModel: a smooth nonlinear least-squares problem\nh: a regularizer such as those defined in ProximalOperators\nχ: a norm used to define the trust region in the form of a regularizer\noptions::ROSolverOptions: a structure containing algorithmic parameters\n\nKeyword arguments\n\nx0::AbstractVector: an initial guess (default: nls.meta.x0)\nsubsolver_logger::AbstractLogger: a logger to pass to the subproblem solver\nsubsolver: the procedure used to compute a step (PG or R2)\nsubsolver_options::ROSolverOptions: default options to pass to the subsolver.\n\nReturn values\n\nxk: the final iterate\nFobj_hist: an array with the history of values of the smooth objective\nHobj_hist: an array with the history of values of the nonsmooth objective\nComplex_hist: an array with the history of number of inner iterations.\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.PG-Tuple{NLPModels.AbstractNLPModel, Vararg{Any}}","page":"Reference","title":"RegularizedOptimization.PG","text":"Proximal Gradient Descent  for\n\nmin_x ϕ(x) = f(x) + g(x), with f(x) β-smooth, g(x) closed, lsc\n\nInput:   f: function handle that returns f(x) and ∇f(x)   h: function handle that returns g(x)   s: initial point   proxG: function handle that calculates prox_{νg}   options: see descentopts.jl Output:   s⁺: s update   s : s^(k-1)   his : function history   feval : number of function evals (total objective )\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.R2-Tuple{NLPModels.AbstractNLPModel, Vararg{Any}}","page":"Reference","title":"RegularizedOptimization.R2","text":"R2(nlp, h, options)\nR2(f, ∇f!, h, options, x0)\n\nA first-order quadratic regularization method for the problem\n\nmin f(x) + h(x)\n\nwhere f: ℝⁿ → ℝ has a Lipschitz-continuous gradient, and h: ℝⁿ → ℝ is lower semi-continuous, proper and prox-bounded.\n\nAbout each iterate xₖ, a step sₖ is computed as a solution of\n\nmin  φ(s; xₖ) + ½ σₖ ‖s‖² + ψ(s; xₖ)\n\nwhere φ(s ; xₖ) = f(xₖ) + ∇f(xₖ)ᵀs is the Taylor linear approximation of f about xₖ, ψ(s; xₖ) = h(xₖ + s), ‖⋅‖ is a user-defined norm and σₖ > 0 is the regularization parameter.\n\nArguments\n\nnlp::AbstractNLPModel: a smooth optimization problem\nh: a regularizer such as those defined in ProximalOperators\noptions::ROSolverOptions: a structure containing algorithmic parameters\nx0::AbstractVector: an initial guess (in the second calling form)\n\nKeyword Arguments\n\nx0::AbstractVector: an initial guess (in the first calling form: default = nlp.meta.x0)\n\nThe objective and gradient of nlp will be accessed.\n\nIn the second form, instead of nlp, the user may pass in\n\nf a function such that f(x) returns the value of f at x\n∇f! a function to evaluate the gradient in place, i.e., such that ∇f!(g, x) store ∇f(x) in g.\n\nReturn values\n\nxk: the final iterate\nFobj_hist: an array with the history of values of the smooth objective\nHobj_hist: an array with the history of values of the nonsmooth objective\nComplex_hist: an array with the history of number of inner iterations.\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.TR-Union{Tuple{X}, Tuple{H}, Tuple{NLPModels.AbstractNLPModel, H, X, ROSolverOptions}} where {H, X}","page":"Reference","title":"RegularizedOptimization.TR","text":"TR(nlp, h, χ, options; kwargs...)\n\nA trust-region method for the problem\n\nmin f(x) + h(x)\n\nwhere f: ℝⁿ → ℝ has a Lipschitz-continuous Jacobian, and h: ℝⁿ → ℝ is lower semi-continuous and proper.\n\nAbout each iterate xₖ, a step sₖ is computed as an approximate solution of\n\nmin  φ(s; xₖ) + ψ(s; xₖ)  subject to  ‖s‖ ≤ Δₖ\n\nwhere φ(s ; xₖ) = f(xₖ) + ∇f(xₖ)ᵀs + ½ sᵀ Bₖ s  is a quadratic approximation of f about xₖ, ψ(s; xₖ) = h(xₖ + s), ‖⋅‖ is a user-defined norm and Δₖ > 0 is the trust-region radius. The subproblem is solved inexactly by way of a first-order method such as the proximal-gradient method or the quadratic regularization method.\n\nArguments\n\nnlp::AbstractNLPModel: a smooth optimization problem\nh: a regularizer such as those defined in ProximalOperators\nχ: a norm used to define the trust region in the form of a regularizer\noptions::ROSolverOptions: a structure containing algorithmic parameters\n\nThe objective, gradient and Hessian of nlp will be accessed. The Hessian is accessed as an abstract operator and need not be the exact Hessian.\n\nKeyword arguments\n\nx0::AbstractVector: an initial guess (default: nlp.meta.x0)\nsubsolver_logger::AbstractLogger: a logger to pass to the subproblem solver (default: the null logger)\nsubsolver: the procedure used to compute a step (PG or R2)\nsubsolver_options::ROSolverOptions: default options to pass to the subsolver (default: all defaut options).\n\nReturn values\n\nxk: the final iterate\nFobj_hist: an array with the history of values of the smooth objective\nHobj_hist: an array with the history of values of the nonsmooth objective\nComplex_hist: an array with the history of number of inner iterations.\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.prox_split_1w-NTuple{4, Any}","page":"Reference","title":"RegularizedOptimization.prox_split_1w","text":"Solves descent direction s for some objective function with the structure \tmins qk(s) + ψ(x+s) s.t. ||s||q⩽ Δ \tfor some Δ provided Arguments ––––– proxp : prox method for p-norm \ttakes in z (vector), a (λ||⋅||p), p is norm for ψ I think s0 : Vector{Float64,1} \tInitial guess for the descent direction projq : generic that projects onto ||⋅||q⩽Δ norm ball options : mutable structure pparams\n\nReturns\n\ns   : Vector{Float64,1} \tFinal value of Algorithm 6.1 descent direction w   : Vector{Float64,1} \trelaxation variable of Algorithm 6.1 descent direction\n\n\n\n\n\n","category":"method"},{"location":"reference/#RegularizedOptimization.prox_split_2w-NTuple{4, Any}","page":"Reference","title":"RegularizedOptimization.prox_split_2w","text":"Solves descent direction s for some objective function with the structure \tmins qk(s) + ψ(x+s) s.t. ||s||q⩽ Δ \tfor some Δ provided Arguments ––––– proxp : prox method for p-norm \ttakes in z (vector), a (λ||⋅||p), p is norm for ψ I think s0 : Vector{Float64,1} \tInitial guess for the descent direction projq : generic that projects onto ||⋅||q⩽Δ norm ball options : mutable structure pparams\n\nReturns\n\ns   : Vector{Float64,1} \tFinal value of Algorithm 6.2 descent direction w   : Vector{Float64,1} \trelaxation variable of Algorithm 6.2 descent direction\n\n\n\n\n\n","category":"method"},{"location":"#RegularizedOptimization.jl","page":"Home","title":"RegularizedOptimization.jl","text":"","category":"section"},{"location":"tutorial/#RegularizedOptimization-Tutorial","page":"Tutorial","title":"RegularizedOptimization Tutorial","text":"","category":"section"}]
}
