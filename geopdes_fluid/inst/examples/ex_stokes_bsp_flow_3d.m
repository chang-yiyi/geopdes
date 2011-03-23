% EX_STOKES_BSP_FLOW_3D: solve the Stokes problem on a twisted pipe using
% a bspline discretization (isoparametric approach).

% 1) PHYSICAL DATA OF THE PROBLEM
clear problem_data  
% Physical domain, defined as NURBS map given in a text file
problem_data.geo_name = 'geo_twisted_pipe.mat';

% Type of boundary conditions for each side of the domain
problem_data.nmnn_sides   = [1 2];
problem_data.drchlt_sides = [3 4 5 6];

% Physical parameters
problem_data.viscosity = @(x, y, z) ones (size (x)); % Functions to compute the viscosity 

% Force term
fx = @(x, y, z) ones(size(x));
fy = @(x, y, z) zeros(size(x));
fz = @(x, y, z) zeros(size(x));
problem_data.f  = @(x, y, z) cat(1, reshape (fx (x,y,z), [1, size(x)]), reshape (fy (x,y,z), [1, size(x)]), reshape (fz (x,y,z), [1, size(x)]));

% Boundary terms
problem_data.h  = @(x, y, z, iside) zeros ([3, size(x)]);%Dirichlet boundary condition
problem_data.g  = @(x, y, z, iside) zeros ([3, size(x)]);%Neumann boundary condition

% 2) CHOICE OF THE DISCRETIZATION PARAMETERS
clear method_data
method_data.element_name = 'TH';
method_data.degree       = [2 2 2];       % Degree of the splines
method_data.regularity   = [1 1 1];       % Regularity of the splines
method_data.nsub         = [1 1 1];       % Number of subdivisions
method_data.nquad        = [4 4 4];       % Points for the Gaussian quadrature rule

% 3) CALL TO THE SOLVER
[geometry, msh, space_v, vel, space_p, press] = solve_stokes_3d_bsplines (problem_data, method_data);

% 4) POST-PROCESSING
% 4.1) EXPORT TO PARAVIEW

output_file = 'TwistedPipe_BSP_Deg2_Reg1_Sub2'

vtk_pts = {linspace(0, 1, 10)', linspace(0, 1, 10)', linspace(0, 1, 10)'};
sp_to_vtk_3d (press, space_p, geometry, vtk_pts, output_file, 'press')
sp_to_vtk_3d (vel,   space_v, geometry, vtk_pts, output_file, 'vel')

% 4.2) PLOT IN MATLAB. COMPARISON WITH THE EXACT SOLUTION

[eu, F] = sp_eval_2d (u, space, geometry, vtk_pts);
[X, Y]  = deal (squeeze(F(1,:,:)), squeeze(F(2,:,:)));
subplot (1,2,1)
surf (X, Y, eu)
title ('Numerical solution'), axis tight
subplot (1,2,2)
surf (X, Y, problem_data.uex (X,Y))
title ('Exact solution'), axis tight

% Display errors of the computed solution in the L2 and H1 norm
return 
% we can work for a better example where the exact solution is known
[error_h1_v, error_l2_v] = ...
           sp_h1_error (space_v, msh, vel, problem_data.velex, problem_data.gradvelex)
error_l2_p = sp_l2_error (space_p, msh, press, problem_data.pressex)

