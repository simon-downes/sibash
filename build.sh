#!/bin/bash

# we're outputting a single file called "sb"
echo "#!/bin/bash" > sb

components="colours core is log input session prompt ui spinner install version"

# cat the component files into output file
for component in $components; do
    cat "src/${component}.sh" >> sb
done

# cat the installer files into output file
for installer in ./src/installers/*; do
    cat $installer >> sb
done

# cleanup goes last
cat "src/cleanup.sh" >> sb

chmod a+x sb
