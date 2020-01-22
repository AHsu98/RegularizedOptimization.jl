# Julia Testing function
# Generate Compressive Sensing Data
using TRNC, Plots,Printf, Convex,SCS, Random, LinearAlgebra
include("./src/minconf_spg/oneProjector.jl")

#Here we just try to solve the l2-norm^2 data misfit + l1 norm regularization over the l1 trust region with -10≦x≦10
#######
# min_x 1/2||Ax - b||^2 + λ||x||₁
# s.t. -10≦x≦10
compound = 1
#m rows, n columns, k nonzeros
m,n = compound*120,compound*512
k = compound*20
p = randperm(n)
#initialize x
x0 = zeros(n,)
x0[p[1:k]]=sign.(randn(k))

A = randn(m,n)
(Q,_) = qr(A')
A = Matrix(Q)
A = Matrix(A')

b0 = A*x0
# b = b0 + 0.005*randn(m,)
b = b0
cutoff = 0.0
# l = -2.0*ones(n,)+cutoff*ones(n,)
# u = 2.0*ones(n,)+cutoff*ones(n,)
l = -10*ones(n,)
u = 10*ones(n,)
λ_T = norm(A'*b, Inf)/50
λ_o = norm(A'*b, Inf)




#define your smooth objective function
#merit function isn't just this though right?
function f_obj(x) #gradient and hessian info are smooth parts, m also includes nonsmooth part
    r = A*x - b
    g = A'*r
    return norm(r)^2, g, A'*A
end

function proxG(z, α)
    return sign.(z).*max.(abs.(z).-(α)*ones(size(z)), zeros(size(z)))
end
#do l2 norm for testing purposes
function projq(z,σ)
    return z/max(1, norm(z, 2)/σ)
end
# projq(z,σ) = oneProjector(z, 1.0, σ)

function h_obj(x)
    return λ_T*norm(x,1)
end
function h_obj2(x)
    return λ_o*norm(x,1)
end
#set all options
#uncomment for OTHER test
first_order_options = s_options(norm(A'*A)^(2.0) ;optTol=1.0e-3, λ=λ_T, verbose=22, maxIter=5, restart=20, η = 1.0, η_factor=.9)
# fo_options=s_options(norm(Bk)^2;maxIter=10, verbose=2, restart=100, λ=λ, η =1.0, η_factor=.9,gk = g, Bk = Bk, xk=x)
#note that for the above, default λ=1.0, η=1.0, η_factor=.9

parameters = IP_struct(f_obj, h_obj2; l=l, u=u, FO_options = first_order_options, s_alg=prox_split_2w, prox_ψk=proxG, χ_projector=projq)
options = IP_options(;simple=0, ptf=50, Δk = k, epsC=.2, epsD=.2)
#put in your initial guesses
x = (l+u)/2
# x = zeros(n,)
zl = ones(n,)
zu = ones(n,)

X = Variable(n)
problem = minimize(sumsquares(A * X - b) + λ_T*norm(X,1), X>=l, X<=u)
solve!(problem, SCSSolver())




x, zl, zu = barrier_alg(x,zl, zu, parameters, options; mu_tol=1e-3)


#print out l2 norm difference and plot the two x values
@printf("l2-norm CVX vs VP: %5.5e\n", norm(X.value - x)/norm(X.value))
@printf("l2-norm CVX vs True: %5.5e\n", norm(X.value - x0)/norm(X.value))
@printf("l2-norm VP vs True: %5.5e\n", norm(x0 - x)/norm(x0))

@printf("Full Objective - CVX: %5.5e     VP: %5.5e   True: %5.5e\n", f_obj(X.value)[1] + h_obj(X.value), f_obj(x)[1]+h_obj(x), f_obj(x0)[1]+h_obj(x0))
@printf("f(x) - CVX: %5.5e     VP: %5.5e   True: %5.5e\n", f_obj(X.value)[1],f_obj(x)[1], f_obj(x0)[1])
@printf("h(x) - CVX: %5.5e     VP: %5.5e   True: %5.5e\n", h_obj(X.value),h_obj(x), h_obj(x0))

plot(x0, xlabel="i^th index", ylabel="x", title="TR vs True x", label="True x")
plot!(x, label="tr", marker=2)
plot!(X.value, label="cvx")
savefig("figs/bpdn/xcomp.pdf")

plot(b0, xlabel="i^th index", ylabel="b", title="TR vs True x", label="True b")
plot!(b, label="Observed")
plot!(A*x, label="A*x: TR", marker=2)
plot!(A*X.value, label="A*x: CVX")
savefig("figs/bpdn/bcomp.pdf")
