To update packages
```
dpkg-scanpackages -m ./debs > Packages && gzip -c Packages > Packages.gz
```