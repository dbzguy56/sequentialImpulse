# Sequential Impulse

## About the project
This project is a work in progress aimed at simulating collision detection and response through sequential impulse in 3D. Jai, OpenGL are used in this project.

Currently the code detects collision using the [gjk algorithm](https://en.wikipedia.org/wiki/Gilbert%E2%80%93Johnson%E2%80%93Keerthi_distance_algorithm). Another great interactive demo of the gjk (and minkowski difference) is located at [this page](https://cse442-17f.github.io/Gilbert-Johnson-Keerthi-Distance-Algorithm/).

It also generates a polytope to determine the penetration depth of the collision using the [EPA algorithm](https://dyn4j.org/2010/05/epa-expanding-polytope-algorithm/).


## Video on Youtube
<a href="http://www.youtube.com/watch?feature=player_embedded&v=4rg4jiwT5mM" target="_blank">
 <img src="http://img.youtube.com/vi/4rg4jiwT5mM/mqdefault.jpg" alt="Watch the video" width="240" height="180" border="10" />
</a>


## Images
![seqImp_1](/assets/images/seqImp_1.png)
![seqImp_2](/assets/images/seqImp_2.png)
![seqImp_3](/assets/images/seqImp_3.png)

From the images above you can see that when the red tetrahedron collides with the blue cube, the green simplex appears. The gjk algorithmn relies on a support function that generates the points that would lie on the minkowski difference of the two colliding objects. These points make up the green simplex, and if this simplex contains the origin, then that means the two objects are colliding! (The black cube being the origin in this case)

The simplex is then used in the next algorithm, the EPA. The expanded polytope is represented in purple (and might even include the green simplex as it extends that). The EPA keeps expanding the original simplex until it can no longer find a closer face on the minkowski difference. The closest point from the origin to a point on EPA's face is the penetration depth. The yellow represents the normals of all of the EPA's faces. The next step would be to use the normal of the closest face and nudge one of the objects in that direction by the depth amount.

## Running the application
You can run the demo by running the following command at the base of the project:

```bash
.\run.bat
```


### Controls
| Input | Action |
| ----- | ------ |
| Mouse | Aim Camera |
| W/A/S/D | Camera Movement |
| Left/Right/Up/Down Arrow Keys | Move the tetrahedron around |
| [/] | Move tetrahedron left to right slower |
| Backspace | Exit program |


## Building
Unfortunately jai isn't released to the public just yet. So if you don't have the compiler, you're out of luck!
Otherwise you just do:

```bash
.\build.bat
```
