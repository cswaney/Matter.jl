using Matter
using Matter: Vector

@testset "vector arithmetic" begin
    a = Vector(0., 1.)
    b = Vector(-1., 2.)
    @test a + b == Vector(-1., 3.)
    @test a - b == Vector(1., -1.)
    @test a * 2 == Vector(0., 2.)
    @test a / 2 == Vector(0., 1. / 2.)
    @test a == Vector(0., 1.)
end

@testset "in-place arithmetic" begin
    a = Vector(0., 1.)
    b = Vector(-1., 2.)
    @test add!(a, b) == Vector(-1., 3.)
    a = Vector(0., 1.)
    @test sub!(a, b) == Vector(1., -1.)
    a = Vector(0., 1.)
    @test mult!(a, 2) == Vector(0., 2.)
    a = Vector(0., 1.)
    @test div!(a, 2) == Vector(0., 1. / 2.)
    a = Vector(0., 1.)
    @test a == Vector(0., 1.)
end

@testset "vector operations" begin
    a = Vector(0., 1.)
    b = cross(a)
    @test det(a, b) == 0.
    @test magnitude(a) == 1.
    @test normalize!(a) == Vector(0., 1.)
    a = Vector(1., 0.)
    rotate!(a, π / 2)
    @test isapprox(a, Vector(0., 1.))
    a = Vector(2., 0.)
    rotate!(a, π / 2, Vector(1., 0.))
    @test isapprox(a, Vector(1., 1.))
end
