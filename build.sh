#!/bin/bash

echo "#!/bin/bash\n" > sb

# cat the files in src excluding the headers into a single file called sb
for file in colours base spinner install; do
    sed -e '1,/# \/HEADER/d' "src/${file}.sh" >> sb
done
