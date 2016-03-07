function [z_irm,z_ibm,t] = apply_ideal_masks(xt,xi,nfft,hop,fs)
%APPLY_IDEAL_MASKS Calculate and apply ideal masks via STFT
% 
%   Z_IRM = APPLY_IDEAL_MASKS(XT,XI) calculates the ideal ratio mask (IRM)
%   and applies it to the mixture XT+XI, where XT is the target signal and
%   XI is the interference signal. The IRM is calculated via the STFT using
%   1024-point windows with 512-point overlap. Z_IRM, XT, and XI are
%   vectors. If XT and XI are of different lengths then the shorter signal
%   is zero-padded in order to make them the same length; Z_IRM is the same
%   length as XT and XI.
% 
%   Z_IRM = APPLY_IDEAL_MASKS(XT,XI,NFFT) uses NFFT-length segments in the
%   STFT.
% 
%   Z_IRM = APPLY_IDEAL_MASKS(XT,XI,WINDOW) uses LENGTH(WINDOW)-length
%   segments in the STFT and applies WINDOW to each segment.
% 
%   Z_IRM = APPLY_IDEAL_MASKS(XT,XI,WINDOW,HOP) uses hop size HOP for the
%   STFT.
% 
%   [Z_IRM,Z_IBM] = APPLY_IDEAL_MASKS(...) calculates the ideal binary mask
%   (IBM) and applies it to the mixture, returning the result to Z_IBM.
% 
%   [Z_IRM,Z_IBM,T] = APPLY_IDEAL_MASKS(XT,XI,WINDOW,HOP,FS) uses sampling
%   frequency FS to return the corresponding time T of each element in
%   Z_IRM and Z_IBM.
% 
%   See also STFT, ISTFT, IDEAL_MASKS, APPLY_MASKS.

%   Copyright 2015 University of Surrey.

% =========================================================================
% Last changed:     $Date: 2015-12-03 22:31:20 +0000 (Thu, 03 Dec 2015) $
% Last committed:   $Revision: 448 $
% Last changed by:  $Author: ch0022 $
% =========================================================================
    
    %% check input
    
    % check signals
    assert(isvector(xt) && numel(xt)>1,'XT must be a vector')
    assert(isvector(xi) && numel(xi)>1,'XI must be a vector')
    
    % make equal length
    maxlength = max([length(xi) length(xt)]);
    xt = pad(xt,maxlength);
    xi = pad(xi,maxlength);
    
    % check nfft
    if nargin<3
        nfft = 1024;
    end
    
    % determine window
    if numel(nfft)>1
        win = nfft;
        assert(isvector(win),'WINDOW must be a vector')
        nfft = length(win);
    else
        assert(round(nfft)==nfft && nfft>0,'NFFT must be a positive integer')
        win = hamming(nfft);
    end
    
    % check x length
    assert(length(xt)>=nfft,'XT must have at least NFFT samples')
    assert(length(xi)>=nfft,'XI must have at least NFFT samples')
    
    % determine hop
    if nargin<4
        hop = fix(nfft/2);
    else
        assert(isscalar(hop) & round(hop)==hop,'HOP must be an integer')
        assert(hop<=nfft && hop>0,'HOP must be less than or equal to NFFT, and greater than 0')
    end
    
    % determine fs
    if nargin<5
        fs = 1;
    else
        assert(isscalar(fs),'FS must be an scalar')
    end
    
    %% calculate outputs
    
    % STFTs of signals and mixture
    st = stft(xt,win,hop);
    si = stft(xi,win,hop);
    mix = stft(xt+xi,win,hop);
    
    % return ideal masks
    [irm,ibm] = ideal_masks(st,si);
    
    % apply IRM
    z_irm = apply_mask(mix,irm,nfft,hop,fs);
    z_irm = pad(z_irm,maxlength);
    
    % apply IBM
    if nargout>1
        z_ibm = apply_mask(mix,ibm,nfft,hop,fs);
        z_ibm = pad(z_ibm,maxlength);
    end
    
    % calculate t
    if nargout>2
        t = (0:length(z_irm)-1)./fs;
    end
    
end

function y = pad(x,dur)
%PAD Zero-pad a vector

    if length(x)<dur
        y = [x(:); zeros(dur-length(x),1)];
    else
        y = x(:);
    end

end
