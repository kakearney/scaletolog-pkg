function [xs, tk, tksc] = scaletolog(x, varargin)
%SCALETOLOG Scale values to logarithmic scale
% 
% [xs, tk, tksc] = scaletolog(x)
% [xs, tk, tksc] = scaletolog(x, prc)
%
% Created so I can apply linear colormaps to logarithmically-scaled data.
% Just spacing the color intervals logarithmically doesn't really work
% since I can't resolve enough color intervals, even with cptcmap.  And a
% simple log transform doesn't work if I have any negative numbers.  This
% function translates the data to a linearly-spaced coordinate; both
% positive and negative directions correspond to log-spaced data, with 0
% translating to both +/- the smallest absolute value in the dataset.
%
% Input variables:
%
%   x:      array of values to be transformed
%
%   prc:    lower percentile of x to be used to set the 0-value in the
%           transformed data.  If not included, the 0-value will be
%           min(log10(abs(x(:)))).
%
% Output variables:
%
%   xs:     Scaled values
%
%   tk:     order-of-magnitude ticks found in the input data (tick labels)
%
%   tksc:   scaled values of these ticks (tick position)

% Copyright 2012 Kelly Kearney

p = inputParser;
p.addParameter('prc', []);
p.addParameter('center', false);
p.parse(varargin{:});
Opt = p.Results;

if ~isempty(Opt.prc)
    centerval = prctile(log10(abs(x(:))), Opt.prc);
else
    centerval = min(log10(abs(x(:))));
end

ismid = real(log10(x)) < centerval;
ispos = x >= 0 & ~ismid;
isneg = x <= 0 & ~ismid;

xs = nan(size(x));
xs(ispos) = log10(x(ispos)) - centerval;
xs(isneg) = -(log10(-x(isneg)) - centerval);
xs(ismid) = 0;

% Some helpful extras

lims = [...
    min(xs(:)) 0 0 max(xs(:))
    min(x(isneg)) -10.^centerval 10.^centerval max(x(ispos))];


lo = real(log10(min(x(:))));
hi = real(log10(max(x(:))));
if Opt.center
    hi = max(lo,hi);
    lo = -hi;
end


tk = [-10.^(ceil(lo):-1:ceil(centerval)) 10.^(ceil(centerval):floor(hi))];
tksc = nan(size(tk));
tksc(tk > 0) = log10(tk(tk > 0)) - centerval;
tksc(tk < 0) = -(log10(-tk(tk < 0)) - centerval);



