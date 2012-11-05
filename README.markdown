#StreetViewDemo#

This is a simple project that uses several open source libraries to mimic the Google StreetView on iOS.  The main view controller uses a JCTiledScrollView to manage user interaction, and loading of each tile's content is done through a datasource method.

The primary problem with this implementation is that the StreetView images have not been corrected to be displayed in a 2D plane.  Instead, they're supposed to be mapped on the inside of a sphere.  Ideally, you would use an OpenGL sphere with lazily loaded textures to accomplish this.  Since this was just a quick demo for StackOverflow, I did not do this.  Instead, I have included Brad Larsen's GPUImage, and have attempted to use CATransform3D to transform each UIImage to kind of fix the perspective problems.  This did not work out perfectly, but can improve the perspective a little bit.  Someone with more time can hopefully configure a better transformation than I did.

As a final note -- Google StreetView has an image request cap of 10 image requests/second.  For this reason, you will see that my code attempts to issue no more than 10 per second.  In actuality, this sometimes doesn't work perfectly, and you may end up with blank tiles because Google is responding with a 403.

**This code is released under the MIT License**