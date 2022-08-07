## $\textbf{Introduction}$
$\text{Fully Connected Neural Network(FNN) is a type of Artificial Neural Network. FNNs has been popular in computer vision, }$ 
$\text{and are gaining popularity in a variety of fields, including radiology}$

$\text{Traditional Fully Connected Neural Networks use CPUs to carry out calculations. Such calculations are wasteful and }$
$\text{slow, and thus make it impossible to meet real-time calculating needs.}$ $\text{As a result, FNNs based on graphics processing }$
$\text{units (GPUs) are commonly used. The literature evaluated CNN open source projects that use GPUs and discovered that }$
$\text{GPUs have some drawbacks, such as high power consumption and high cost. Taking this into account, FPGA is a}$
$\text{better fit as it is a low power device, which provides a similar degree of acceleration }$
$\text{to a GPU.}$

$\text{In this project fully connected neural network is implemented in synthesizable} \textbf{ Verilog}.$ $\text{This is deployable}$
$\text{on FPGAs after some minor changes.}$

## $\textbf{General FNN structure}$
$\text{Fully Connected Neural Network composed of multiple layer and each layer have a fixed number of neurons. All these }$
$\text{layers also include input layer and output layer and remaining are the hidden layers.}$

![FNN](https://user-images.githubusercontent.com/91585086/183276654-58cde0ca-0cef-4131-903d-e5f574b42baa.png)
   
$\text{ Since neruon is a basic bulding block of a forward neural network so its necessary to discuss its general structure.}$

## $\textbf{Neuron}$
$\text{A neuron have many inputs and one output. Each input is multiplied by a corresponding weight and an overall bias}$
$\text{is added. After that this result is applied to an activation function that gives the finial output.}$

![General_structure_neuron](https://user-images.githubusercontent.com/91585086/183300664-178cc740-6eb4-44ac-9140-2a4b7d264574.png)

## $\textbf{Implementation of a Neuron in Verilog}$
$\text{The neuron is designed in such a way that it accepts the input image data}$ $\textbf{ sequentially}$ $\text{ in the }$ $\textbf{fixed point binary}$
$\text{format. Every Neuron has its own small RAM to store weights(It will be discussed how weights will arrive in RAM of }
$\text{each neuron.)}$

