
cat $1 > z

cat <<EOF > ss
s/ mov / movs /;
s/ add / adds /;
s/ and / ands /;
s/ orr / orrs /;
s/ eor / eoss /;
EOF

sed -
