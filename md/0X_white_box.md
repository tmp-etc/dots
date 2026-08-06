https://portswigger.net/research/pre-auth-rce-in-forgerock-openam-cve-2021-35464 
> As my intention was to find truly impactful vulnerabilities rather than just "something", I decided to focus on the systems that are either open source or available to download and decompile.

https://j0vsec.com/post/cve-2021-43798/

https://pentesterlab.com/blog/how-to-start-reviewing-code

---

# INSECURE DESERIALIZATION

- You provide the serialized data/string, app deserializes it
- Your input end in some sort of custom serialization implementations where the serialized value is created through concatenation (see CVE-2025-49113)
    - could be named something like `objectmanager` (as in Magento)

If the app limits classes it is willing to deserialize or is deserializing an item it previously serialized itself...
- Check if the class (or any allowed classes) have known-exploitable magic methods, i.e a property (that you control) is used 'dangerously' inside the magic method, like `$this->$foo->something()` or `something_dangerous($this->$foo)` ... sounds stupid but hey


# ARBITRARY FILE WRITE / FILE UPLOAD

- The file gets turned into a file in underlying filesystem (I guess cloud storage like buckets handle this differently)
- You control the (part of the) filepath and the file content
- You are able to bypass sanitization of the filepath and content
- You find a path from which this file gets handled like an executable

This could range from classic webshells to messing with session data like CVE-2026-41940 where sessions are stored in plaintext file as key-value pairs and appending newline characters to a value enabled to insert new keys

Could also write bytecode to an open file descriptor file or something

# SSTI

Your input ends up
- in a logical (or logicful?) template engine, such as Mustache
- in some sort of string interpolation / replacement that's used to construct the template before handing it over to the templating engine
- in an in-template func that's RCE-ish
- as the whole template to be templated (lol), either via string or file upload

# REMOTE FILE INCLUSION
Like `import`, `require` in PHP. Basically can you make the app take your code and include it in theirs.

# SUPPLY CHAIN / CICD ATTACKS

Lore ipsum
...
...

# DATA EVALUATED AS CODE

Be it calling executables from the underlying OS or pushing a string to a code engine to be evaluated as code.

Keep in mind that you may not be able to manipulate the arguments of the executable, but you still could have some other input opportunities (like commands to a file that the executable will parse and execute, see CVE-2025-60787).

# AUTHN/Z BYPASSES

Especially when there are 'legit' functionalities that enable code execution, uploading webshells etc.

# ARBITRARY DATA READ

Be it reading files or from a database etc etc.

Check if the file is returned to you in some shape or form.

# SSRF

TBA, prolly only if you can hit some internal endpoint that enabled code exec etc...

