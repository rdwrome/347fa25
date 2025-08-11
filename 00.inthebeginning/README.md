# in the beginning

- Big Picture
- Introductions
- GitHub vs Canvas
  - everyone in the GitHub
  - clone this repo

## Syllabus

## Listening List

## Install [SuperCollider](https://supercollider.github.io/)
  - 343/tidal cycles fyi

## Object - Oriented, based on smalltalk (old general use language)
- **Encapsulation**
- object: independent part of the program that manages itself (own rules and ways of doing things); a representation of something that you can control and send messages to
- **Inheritance**
- objects get their functions from classes
- class: template, blueprint for creating objects
- superclass is parent, class is child
- class inherits attributes of parent (through abstraction) but modifies, evolves
- classes are reusable
- **Polymorphism**
- change the way something works by overriding and overloading
- change type, have multiple types work together
- overriding: walk backwards
- overloading: walk to run 

## [Open Sound Control](https://ccrma.stanford.edu/groups/osc/index.html)
- Client and Server communicate in OSC messages

## Getting Started with SuperCollider
- What you downloaded was actually three things:
  - sclang (client), scserver (server), scide
- [Client vs Server](https://doc.sccode.org/Guides/ClientVsServer.html)
- You can run server(s) from anything/anywhere
- IDE: Text Editor, Post window, Help browser
- Client (Interpreter/Language) boots when you open IDE
- You do need to boot the Audio Server with **Command|B**
- You see your I/O in the Post window after booting the Audio Server
- [You might need to change them/select them with this code](https://doc.sccode.org/Reference/AudioDeviceSelection.html)
- If you I/O audio rates don't match, the server won't boot and you'll need to make sure they match in your Audio MIDI setup
- Evaluate a line with **Shift|Return**
- Evaluate a block with **Command|Return**
- Kill what is on the server with **Command|.**
- ***Beware Zombie servers***
- Everything's in mono by default
- "Syntax Sugar": many ways to write out the same thing
- Help! with **Command|D**

## CODEALONG.scd in this folder
