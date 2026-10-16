#!/bin/sh
# Build the ipextra Debian package from repo sources. Run from repo root.
set -e
VERSION=1.1-1
NAME=ipextra_${VERSION}_all
STAGE=build/$NAME
rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin" "$STAGE/usr/share/ipextra" "$STAGE/usr/share/doc/ipextra" "$STAGE/DEBIAN"
cp ipextra.sh "$STAGE/usr/bin/ipextra"
cp ipextra.awk "$STAGE/usr/share/ipextra/ipextra.awk"
cp README.md "$STAGE/usr/share/doc/ipextra/README.md"
sed "s/@VERSION@/$VERSION/" debian.control > "$STAGE/DEBIAN/control"
chmod 755 "$STAGE/usr/bin/ipextra"
chmod 644 "$STAGE/usr/share/ipextra/ipextra.awk" "$STAGE/usr/share/doc/ipextra/README.md" "$STAGE/DEBIAN/control"
dpkg-deb --build --root-owner-group "$STAGE" "$NAME.deb"
echo "Built $NAME.deb"
