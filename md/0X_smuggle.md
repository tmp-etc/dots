>[!note]
> First, <u>focus on the sink</u>. Would your bypass/alternate syntax be interpreted as the payload you are trying to smuggle in?
> 
> If so, then move on to the filter function to see if you can smuggle your bypass through it.

## Inconsistencies in handling alternate syntax - filter vs sink [^4]
In handling both 'normal' and 'special' chars
1. encoding (parts of) the string
	-  URL
		-  double URL encoding		
		-  maybe overlong URL? [^3] 
			- |Character|Encoded[^5]|
		  |---|---|
		  |`.`|`%c0%2e`, `%e0%40%ae`, `%c0%ae`|
		  |`/`|`%c0%af`, `%e0%80%af`, `%c0%2f`|
		  |`\`|`%c0%5c`, `%c0%80%5c`|
2. ascii / unicode escape syntax [^2] 
> [!note]
> When you send data as a JSON HTTP request body, the JSON parser will process the escape sequences according to JSON specification before PHP (or whatever else) ever sees the data.
> 
> So you have to <u>**use**</u> (in this case) <u>**the JSON specific escape syntax**</u>. Once the JSON is parsed, PHP will have the actual Unicode character in its internal string representation. <u>**PHP's `\u{xxxx}` (or any other) syntax is only relevant when you're writing PHP source code directly**</u>, not when receiving JSON data.
>
> In case of `application/x-www-form-urlencoded` and `multipart/form-data` you should <u>**send the actual UTF-8 encoded bytes**</u> of the character
>
> For <u>**URL query strings**</u>, Unicode characters beyond ASCII should be <u>**percent-encoded**</u> (URL-encoded) as UTF-8 bytes.
> The emoji (U+1F600) becomes:
>
> 1. UTF-8 encode: `0xF0 0x9F 0x98 0x80`
> 2. Percent-encode: `%F0%9F%98%80`
> 3. Final URL: `https://example.com/search?q=%F0%9F%98%80`
	- apparently also `%u<unicode codepoint>` [^6]
	
2. unicode normalization (including emojis?)
3. overlong unicode -- https://kevinboone.me/overlong.html
4. unicode trunc / overflow -- https://portswigger.net/research/bypassing-character-blocklists-with-unicode-overflows
5. using UTF-16 and the like?
6. modifying the `Content-Type` header to use a different charset (e.g. `ibm500`)[^1]; also check out [[Breaking Down Multipart Parsers_ File upload validation bypass.pdf|this]] - more likely when filter is implemented as a separate software component
7. for CLI (and path traversal?) injections using wildcards, like `/???/??t /???/??ss??` -> `/bin/cat /etc/passwd`

## Fooling the (regex based) filter
1. control characters before the naughty special chars to prematurely end parsing
2. other invisible characters to mess with the regex filter
3. using other characters in the payload that break the filter and (potentially) get ignored by the sink; like in Bash `..\/..\/..\/..\/etc/hosts` ends up being `../../../../etc/hosts`
4. adding the triggering character multiple times (like `......//`, `..././` <- the middle dotdotslash get remove, resulting in another dotdotslash)
5. lots of other params before the param that you are interested in (to also prematurely stop the string parsing in the filter); also see https://github.com/assetnote/nowafpls
6. really long values - same idea, input is trucated, leaving only your payload to be executed
7. parameter pollution - filter checks one, sink uses other
8. case differences
9. using comments to break up the string (like `/?id=1+un/**/ion+sel/**/ect+1,2,3--`)
10. for CLI injections using non-existant env variables, like `si${foo}imu` -> `siimu`
11. if possible, using concatenation to bypass filters that look for keywords

## Inconsistent use of filters in functions
1. different HTTP method

[^1]: A WAF that is not configured to detect malicious payloads in different encodings may not recognize the request as malicious. The charset encoding can be done in Python `urllib.parse.quote_plus(s.encode("IBM037"))` or using <u>Hackvertor</u>!

[^2]: Although for C, I guess [[Pasted image 20250819141511.png|this]] is a good representation of different ways to do this as well 

[^3]: Well, potentially, see [[Pasted image 20240718183254.png|this]]). For background knowledge, see [[Kevin Boone_ UTF-8 and the problem of over-long characters.pdf|this]]. Burp also lets you test this pretty easily in Intruder: *Payload type -> Illegal Unicode -> Match/replace in list items - select which chars to encode*.

[^4]: For instance, PHP’s `fopen()` might look like a candidate for Unicode smuggling. PHP string literals support the `\u{hhhh}` syntax (in addition to `\xhh`), but PHP itself is implemented in C. In C, however, the unicode escape follows the `\uhhhh` syntax, and these escapes are only meaningful in wide-character contexts (also see [this](https://en.wikipedia.org/wiki/Escape_sequences_in_C#Universal_character_names)), not in normal `char *` strings. Unless the developer explicitly decodes the input through something like `json_decode()` (because `\uhhhh` is a valid escape sequence in JSON), a payload such as `filename=shell.ph\u0070` is passed as a literal string `"shell.ph\u0070"` directly into `fopen()`. Moreover, `fopen()` takes a `char *` and simply forwards raw bytes to the filesystem without additional Unicode escape processing or normalization (see [this](https://github.com/php/php-src/blob/master/ext/standard/file.c#L724)).

[^5]: From https://swisskyrepo.github.io/PayloadsAllTheThings/Directory%20Traversal/#overlong-utf-8-unicode-encoding

[^6]: As seen here https://swisskyrepo.github.io/PayloadsAllTheThings/Directory%20Traversal/#unicode-encoding
