function [ in_region, on_region ] = NM_inregion( query_points, region_vertex )
% NM_INREGION Verify if the vertex are inside the specified region (function 
%   inherited from MATLAB inpolygon)
%
%   Copyright: Niki Martinel
%   Date: 09/29/2011
%   Return Data: True/false for points in region or on region edge
%   Parameters: 1. nx2 matrix conteining [x1 y1; x2 y2; ... ] 
%                  coordinate of query points
%               2. mx2 matrix containing region coordinates
%                  [x1 y1; x2 y2; ....]
%               
%   [IN_REGION, ON_REGION] = NM_INREGION(QUERY_POINTS,REGION_VERTEX)
%   takes as input data the coordinate points REGION_VERTEX that define 
%   the region on which test the query vertex QUERY_POINTS
%
%   [IN_REGION] = NM_INREGION(QUERY_POINTS, REGION_VERTEX)
%   returns a matrix IN_REGION the size of QUERY_POINTS.
%   IN(p,q) = 1 if the point QUERY_POINTS(p,q) is either strictly inside or
%   on the edge of the polygonal region whose vertices are specified by the
%   vectors REGION_VERTEX otherwise IN(p,q) = 0.
%
%   [IN_REGION, ON_REGION] = NM_INREGION(QUERY_POINTS, REGION_VERTEX)
%   returns a second matrix, ON_REGION, which is 
%   the size of QUERY_POINTS. 
%   ON_REGION(p,q) = 1 if the point QUERY_POINTS(p,q) is on the edge 
%   of the polygonal region otherwise ON(p,q) = 0.
%
%   QUERY_POINTS should be a matrix of size nx2
%
%   REGION_VERTEX should be a matrix of size mx2 containing
%   region coordinate points. First and last element x,y coordinates must
%   be the same for closed regions
%t
%   IN_REGION is a matrix of the same size of QUERY_POINTS
%
%   ON_REGION is a matrix of the same size of QUERY_POINTS
%
[in_region, on_region] = inpoly(query_points, region_vertex);

end

