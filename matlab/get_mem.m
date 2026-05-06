function m = get_mem(pid)
    [~, out] = system(sprintf('ps -o rss= -p %d', pid));
    m = str2double(out); % KB
end