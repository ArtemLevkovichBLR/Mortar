![Mortar](/Development/Art/Banner.png)

Mortar allows you to create Auto Layout constraints using concise, simple code statements.

```swift
addConstraint(NSLayoutConstraint(
    item:        view1,
    attribute:  .Right,
    relatedBy:  .Equal,
    toItem:      view2,
    attribute:  .Left,
    multiplier:  1.0,
    constant:   -12.0
))
```

Turns into:

```swift
view1.m_right |=| view2.m_left - 12.0
```

# Usage

Mortar does not require closures of any kind.  The Mortar operators (```|=|```, ```|>|``` and ```|<|```) instantiate and return constraints that are activated by default.  

Mortar will set ```translatesAutoresizingMaskIntoConstraints``` to ```false``` for every view declared on the left side of an operator.


### Equal, Less or Greater?

There are three mortar operators:

```swift
view1.m_width |=| 40                // Equal
view1.m_width |>| view2.m_width     // Greater than or equal
view1.m_size  |<| (100, 100)        // Less than or equal
```

### Attributes

Mortar supports all of the standard layout attributes:

* ```m_left```                   
* ```m_right```                  
* ```m_top```                    
* ```m_bottom```                 
* ```m_leading```                
* ```m_trailing```               
* ```m_width```                  
* ```m_height```             
* ```m_centerX```            
* ```m_centerY```            
* ```m_baseline```           

And iOS/tvOS spceific attributes:

* ```m_firstBaseline```     
* ```m_leftMargin```         
* ```m_rightMargin```        
* ```m_topMargin```          
* ```m_bottomMargin```       
* ```m_leadingMargin```      
* ```m_trailingMargin```     
* ```m_centerXWithinMargin```
* ```m_centerYWithinMargin``` 

It also supports composite attributes:

* ```m_sides -- (left, right)```
* ```m_caps -- (top, bottom)```
* ```m_size -- (width, height)```
* ```m_center -- (centerX, centerY)```
* ```m_cornerTL -- (top, left)```
* ```m_cornerTR -- (top, right)```
* ```m_cornerBL -- (bottom, left)```
* ```m_cornerBR -- (bottom, right)```
* ```m_edges -- (top, left, bottom, right)```
* ```m_frame -- (top, left, width, height)```

### Implicit Attributes

_Mortar will do its best to infer implicit attributes!_

The ```m_edges``` attribute is implied when no attributes are declared on either side: 

```swift
view1.m_edges |=| view2.m_edges     // These two lines
view1         |=| view2             // are equivalent.
```

If an attribute is declared on one side, it is implied on the other:

```swift
view1.m_top   |>| view2             // These two lines
view1         |>| view2.m_top       // are equivalent.
```

You are required to put attributes on both sides if they are not the same:

```swift
view1.m_top   |<| view2.m_bottom
```

### Multipliers and Constants

Auto Layout constraints can have multipliers and constants applied to them.  This is done with normal arithmetic operators.  Attributes must be explicitly declared on the _right_ side When arthmetic operators are used.

```swift
view1.m_size  |=| view2.m_size  * 2         // Multiplier   
view1.m_left  |>| view2.m_right + 20        // Constant
view1         |<| view2.m_top   * 1.4 + 20  // Both -- m_top is implied on the left
```

You can also set attributes directly to constants:

```swift
view1.m_width |=| 100                // Single-dimension constants
view1.m_size  |=| 150.0              // Set multiple dimensions to the same constant
view1.m_size  |>| (200, 50)          // Set multiple dimensions to a tuple value
view1.m_frame |<| (0, 0, 50, 100)    // Four-dimension tuples supported
```

Arithmetic can be done using tuples for multi-dimension attributes:

```swift
view1.m_size  |=| view2.m_size + (50, 30)
view1.m_size  |>| view2.m_size * (2, 3) + (10, 10)
```

The special inset operator ```~``` operates on multi-dimension attributes:

```swift
view1         |=| view2.m_edges ~ (20, 20, 20, 20)  // view1 is inset by 20 points on each side
```

### Attributes in Tuples

You are allowed to put attributes inside of tuples:

```swift
view1.m_size  |=| (view2.m_width, 100)
```

### Multiple Simultaneous Constraints

Multiple constraints can be created using arrays:

```swift
view1 |=| [view2.m_top, view3.m_bottom, view4.m_size]

/* Is equivalent to: */
view1 |=| view2.m_top
view1 |=| view3.m_bottom
view1 |=| view4.m_size
```

```swift
[view1, view2, view3].m_size |=| (100, 200)

/* Is equivalent to: */
[view1.m_size, view2.m_size, view3.m_size] |=| (100, 200)

/* Is equivalent to: */
view1.m_size |=| (100, 200)
view2.m_size |=| (100, 200)
view3.m_size |=| (100, 200)
```

This might be a convenient way to align an array of views, for example:

```swift
[view1, view2, view3].m_centerY |=| otherView
[view1, view2, view3].m_height  |=| otherView
```

### Priority

You can assign priority to constraints using the ```!``` operator.  Valid priorities are:

* ```.Low```, ```.Default```, ```.High```, ```.Required```
* Any ```UILayoutPriority``` value

```swift
v0 |=| self.container.m_height
v1 |=| self.container.m_height ! .Low
v2 |=| self.container.m_height ! .Default
v3 |=| self.container.m_height ! .High
v4 |=| self.container.m_height ! .Required
v5 |=| self.container.m_height ! 300
```

You can also put priorities inside tuples or arrays:

```swift
view1        |=| [view2.m_caps   ! .High, view2.m_sides      ! .Low]  // Inside array
view1.m_size |=| (view2.m_height ! .High, view2.m_width + 20 ! .Low)  // Inside tuple
```

### Change Priority

You can change the priority of a ```MortarConstraint``` or ```MortarGroup``` by calling the ```changePriority``` method.  This takes either a ```MortarLayoutPriority``` enum, or a ```UILayoutPriority``` value:

```swift
let c = view1 |=| view2 ! .Low     // Creates 4 low-priority constraints (1 per edge)
c.changePriority(.High)            // Sets all 4 constraints to high priority
```

Remember that you can't switch to or from ```Required``` from any other priority level (this is an Auto Layout limitation.)


### Create Deactivated Constraints

You can use the ```~~``` operator as a shorthand for constraint activation and deactivation.  This makes the most sense as part of constraint declarations when you want to create initially-deactivated constraints:

```swift
let constraint = view1 |=| view2 ~~ .Deactivated

// Later on, it makes more semantic sense to call .activate():
constraint.activate()

// Even though this is functionally equivalent:
constraint ~~ .Activated

// It works with groups too:
let group = [
    view1 |=| view2
    view3 |=| view4
] ~~ .Deactivated

```

# Keeping Constraint References

The basic building block is the ```MortarConstraint```, which wraps several ```NSLayoutConstraint``` instances that are relevant to multi-affinity attributes like ```m_frame``` (4) or ```m_size``` (2).

You can capture a ```MortarConstraint``` for later reference:

```swift
let constraint = view1.m_top |=| view2.m_bottom
```

The raw ```NSLayoutConstraint``` elements can be accessed through the ```layoutConstraints``` accessor:

```swift
let mortarConstraint = view1.m_top |=| view2.m_bottom
for rawLayoutConstraint in mortarConstraint.layoutConstraints {
    ...
}
```

You can create an entire group of constraints:

```swift
let group = [
    view1.m_origin |=| view2,
    view1.m_size   |=| (100, 100)
]
```

Mortar includes a convenient typealias to refer to arrays of ```MortarConstraint``` objects:

```swift
public typealias MortarGroup = [MortarConstraint]
```

You can now activate/deactivate constraints:

```swift
let constraint = view1.m_top |=| view2.m_bottom

constraint.activate()
constraint.deactivate()

let group = [
    view1.m_origin |=| view2,
    view1.m_size   |=| (100, 100)
]

group.activate()
group.deactivate()
```

### Replacing Constraints and Groups of Constraints

Constraints and groups have a replaceWith method that deactives the target and activates the parameter:

```swift
let constraint1 = view1.m_sides |=| view2
let constraint2 = view1.m_width |=| view2 ~~ .Deactivated

constraint1.replaceWith(constraint2)

let group1 = [
    view1.m_sides |<| view2,
    view1.m_caps  |>| view2,
]
        
let group2 = [
    view1.m_width |=| view2
] ~~ .Deactivated

group1.replaceWith(group2)
```

# Visual View Hierarchy Creation

Mortar provides the ```|+|``` and ```|^|``` operators to quickly add a subview or array of subviews.  This can be used to create visual expressions of the view hierarchy.

Now this:

```swift
self.view.addSubview(backgroundView)
self.view.addSubview(myCoolPanel)
myCoolPanel.addSubview(nameLabel)
myCoolPanel.addSubview(nameField)
```

Turns into:

```swift
    self.view |+| [
        backgroundView,
        myCoolPanel |+| [
            nameLabel,
            nameField
        ]
    ]
```

Alternatively, if you want to see the upper subviews at the beginning of the array (so that visually, the views closer to the top of the file are closer to the user), use the ```|^|``` operator:

```swift
    self.view |^| [
        myCoolPanel |^| [      // myCoolPanel is added second and
            nameField,         // is therefore on top of backgroundView
            nameLabel
        ],
        backgroundView        
    ]
```