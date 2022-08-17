## $\textbf{Introduction}$
Fully Connected Neural Network(FNN) is a type of Artificial Neural Network. FNNs has been popular in computer vision, and are gaining popularity in a variety of fields, including radiology

Traditional Fully Connected Neural Networks use CPUs to carry out calculations. Such calculations are wasteful and slow, and thus make it impossible to meet real-time calculating needs.}$ $\text{As a result, FNNs based on graphics processing units (GPUs) are commonly used. The literature evaluated CNN open source projects that use GPUs and discovered that GPUs have some drawbacks, such as high power consumption and high cost. Taking this into account, FPGA is a better fit as it is a low power device, which provides a similar degree of acceleration to a GPU.

In this project fully connected neural network is implemented in synthesizable \textbf{ Verilog}. This is deployable on FPGAs after some minor changes.

## $\textbf{General FNN structure}$
Fully Connected Neural Network composed of multiple layer and each layer have a fixed number of neurons. All theselayers also include input layer and output layer and remaining are the hidden layers.

![FNN](https://user-images.githubusercontent.com/91585086/183276654-58cde0ca-0cef-4131-903d-e5f574b42baa.png)
   
Since neruon is a basic bulding block of a forward neural network so its necessary to discuss its general structure.

## $\textbf{Neuron}$
A neuron have many inputs and one output. Each input is multiplied by a corresponding weight and an overall bias is added. After that this result is applied to an activation function that gives the finial output.
![General_structure_neuron](https://user-images.githubusercontent.com/91585086/183300664-178cc740-6eb4-44ac-9140-2a4b7d264574.png)

## $\textbf{Implementation of a Neuron in Verilog}$
The neuron is designed in such a way that it accepts the input image data$\textbf{ sequentially}$ in the $\textbf{fixed point binary}$ format. Every Neuron has its own small RAM to store weights(It will be discussed how weights will arrive in RAM of each neuron.). When the "In-data-valid" becomes "1" controller enables both the counter and RAM. Counter is reseted to 0. After that input data start arriving sequentially. For every pixel of input image corresponding weight is fetched from memory and fed to multiplier after sign extentsion(Not required for some neruon). When multiplication is completed it is fed to an adder that already have previously stored multiplication result as its input. After that result is again loaded in a register and this continues to repeat until counter reaches to the second last address of RAM. At the last address bias is stored. After that bias is fetched from memory and added directly to last data of register after sign extention. After that "Demux-control" signal is made high that connects output of register to activation function. Activation function gives the finial result.
![neuron_arch_finial](https://user-images.githubusercontent.com/91585086/185057835-dd9982d7-2b5f-4022-9ea8-cdf666c66fcf.png)

## $\text{Architecture of FNN}$
In the implemented design, the architecture of a forward neural network consists of four neural layers(named layer1, layer2, layer3, layer4), maxfinder module and a controller. Layer1 have 40 neurons, layer2, layer3 and layer4 have 10 neurons. Since each neuron in the layers recieve the data sequentially but all neruons in a layer produce their result together so for parallel to serial conversion a PISO shift register is also placed in between two layers. The dataflow inside PISO shift register is controlled by three control signal named "enable", "reset", "shift".
$\text{This PISO shift register serve two purpose here, (1.) Convert parallel data output of each neruon to serial form so that it can be received by the next layer. (2.) It also helps in implementing layer level pipelining just by making some changes in the architecture of controller.


###$\text{How data flow happens in implemented FNN}
$
$\text{Click on the image to see clearly}$
![FNN_architecture drawio](https://user-images.githubusercontent.com/91585086/183919382-66d06d39-17b9-421f-a605-636b71f88775.png)



