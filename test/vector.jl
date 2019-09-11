using Matter

@testset "vector arithmetic" begin
    a = Matter.Vector(0., 1.)
    b = Matter.Vector(-1., 2.)
    @test a + b == Matter.Vector(-1., 3.)
    @test a - b == Matter.Vector(1., -1.)
    @test a * 2 == Matter.Vector(0., 2.)
    @test a / 2 == Matter.Vector(0., 1. / 2.)
end

@testset "vector operations" begin
    a = Matter.Matter.Vector(0., 1.)
    b = Matter.cross(a)
    @test Matter.det(a, b) == 0.
end
