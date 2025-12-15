2021 IEEE Conference on Communications and Network Security (CNS) | 978-1-6654-4496-5/21/$31.00 ©2021 IEEE | DOI: 10.1109/CNS53000.2021.9729037
GeoSecure-C: A Method for Secure GPS Trajectory
Compression Over Cloud
Vikram Patil!, Shivam Parikh!, Omkar N. Kulkarni!, Kalika Bhatia∗ and Pradeep K. Atrey!
!Department of Computer Science, University at Albany - SUNY, NY, USA
∗Lynbrook High School, San Jose, CA, USA
Email: {vpatil, sparikh, onkulkarni, patrey}@albany.edu, kbhatia247@student.fuhsd.org
Abstract—Today, the use of Location-Based Services (LBS) is
increasing exponentially. These LBS are generally based on GPS
data, which is typically stored over cloud. As the number of users
and their frequency of using LBS is increasing, the data generated
by them is also increasing. Therefore, compression of the GPS data
is paramount. Also, GPS data is extremely sensitive and needs
to be protected. Existing approaches for compressing GPS data
do not focus on the security or the privacy aspect of it. In this
paper, we present a novel method, called GeoSecure-C, to securely
compress the GPS data without knowing users’ actual location.
The proposed method is tested on Microsoft’s GeoLife dataset
and yields a similar compression ratio on the secured trajectory
as that of the original trajectory.
Index Terms—Trajectory simplification, GPS, Compression,
Location privacy
Fig. 1: GeoSecure-C workflow
I. INTRODUCTION
Wider adoption of 5G as mainstream technology will result
in the proliferation of Location-based Services (LBS) enabled
applications and the generation of a huge amount of GPS data
in groundbreaking ways [1]. This data is generally stored on
the cloud, i.e., with a cloud service provider (CSP) by the LBS
provider. To store the data and to transfer it between users
and the CSP, the LBS provider has to pay the cost. In order
to reduce the storage cost, LBS providers often compress the
GPS data using trajectory compression methods, such as the
Douglas-Peucker (DP) simplification algorithm [2]. Trajectory
simplification is a process of representing trajectory with a
minimum number of points in such a way that the shape of
the compressed trajectory matches the original trajectory.
The GPS data can reveal users’ personal information such
as places visited, shopping preferences, healthcare provider
visits, religious and political affiliations. Hence, we need to
protect it and come up with ways that provide privacy-enabled
LBS. There are several methods proposed in the literature
for compressing the GPS data. However, to the best of our
knowledge, the problem of secure GPS trajectory simplifi-
cation/compression is not yet addressed. Secure GPS data
compression refers to compressing the data without revealing
users’ location and protecting it from external adversaries as
well as curious LBS providers.
There are a few approaches in the literature proposed for
secure GPS data compression. For instance, Kryptein [3],
Xue et al. [4] and Rana et al. [5] used compressive sensing
based method to derive the features from the trajectory for
sparse learning and compression. Also, in [6], Acharya and
Gaur proposed a novel method for securely compressing GPS
trajectory data using an edge computing based approach in
which map matching and a dictionary of the users’ locations
is kept at the users’ device, and then its indexes are sent to
the CSP. In all these methods, the trajectory is reconstructed at
the LBS provider side. Hence, they do not protect against the
semi-malicious or curious LBS provider.
To overcome the above mentioned issue, we propose a
method, called GeoSecure-C, to implement a lossy compression
method (i.e. the DP algorithm) in a privacy-ensured way, i.e.,
without revealing users’ location to the LBS provider. The key
idea behind the proposed method is to adopt the GeoSecure-
R method [7] and integrate it with the DP line simplification
algorithm. The main difference between the proposed method
and our previous works on GeoSecure series [8], [9], [7] is
that the proposed method provides lossy compression using DP,
while the focus in [8], [9], [7] was to calculate the travelled
distance preserving location privacy of users. The proposed
method is inspired from the Trajic [10], which uses delta
compression (lossless) and predictor function (lossy), but this
approach does not focus on privacy. Instead, their focus is on
the storage and query processing system.
II. PROPOSED METHOD
The workflow of the proposed GeoSecure-C method is
shown in Fig. 1. The proposed method uses the GeoSecure-
R approach to transform the trajectory. This is achieved using
delta compression on the user’s device. The first point is kept at
the user’s device, and the differences between successive points
are sent to the CSP. The LBS provider uses the center of the
city in which these trajectories are recorded along with these
differences to create a transformed trajectory (we call it, the
secured trajectory). The transformed (or secured) trajectory is
Authorized licensed use limited to: UNIVERSITY AT ALBANY SUNY. Downloaded on September 29,2022 at 17:57:06 UTC from IEEE Xplore. Restrictions apply.
Fig. 2: Compression ratio CR for original trajectories and
secured trajectories
secure (as shown in [7]) and possesses the same shape as the
original (or plaintext) trajectory.
A. Secure Trajectory Compression
We apply the DP Algorithm on both the original trajectory
and the secured trajectory. Since the DP algorithm is based on
calculating Euclidean distances, the result of the simplification
is the same in the case of original and secure trajectory. A
similar argument can also be made for the haversine distance.
The proposed method follows these steps:
1) Store the first point of the trajectory at the user’s device.
2) Multiply each point with 106 so that the resultant will be
in natural numbers. Subtract the previous point from the
current point.Send the differences to the LBS provider or
the CSP. (Similar to GeoSecure-R [7])
3) Add the first point as the center of the geographic location.
(In this case, it is the center of Beijing.)
4) Starting with the second point difference, add it with its
previous point. This will create the secured trajectory.
5) Apply DP algorithm on this secured trajectory and get the
set of the simplified points after compression.
6) Send the indices of these points back to the user’s device,
which can then choose the corresponding points from the
original trajectory and achieve the simplification securely.
B. Experimental Validation
We used Microsoft’s GeoLife dataset [11] for experiments.
We use the compression ratio (CR) as the error metric, which
is defined as the ratio of simplified points to the points in the
original trajectory. CRis computed as, CR= 1−
|T ′ |
|T | ×100,
where T ′ is the simplified version of the original trajectory T
and |.|represents the number of points in a given trajectory.
We tested the proposed method on 18,000+ trajectories from
the dataset. For every trajectory, we created a corresponding
secured trajectory. We first ran the DP algorithm on the original
trajectory and then recorded the number of points in the
trajectory, simplified points, and CR. Similarly, we ran the
DP algorithm on the transformed trajectory and recorded the
same three parameters. For the DP algorithm implementation,
we have used the Shapely library in python. We also referred
the source code written by Geoff Boeing for trajectory simplifi-
cation using DP algorithm and visualization [12] and modified
it further. Fig. 2 depicts the histogram of the CRfor both the
original trajectories and the secured trajectories. Note that they
are the same. Therefore, we can say that the proposed method
yields the same compression ratio in the secured trajectory as
that of the original trajectory.
III. CONCLUSION AND FUTURE WORK
In this paper, we presented a novel approach for securely
compressing GPS trajectory data. We observed that the pro-
posed method achieves the same compression ratio in the
secure trajectory as that of the original trajectory. The proposed
method protects users’ GPS trajectory data from external as
well as semi-malicious/curious service providers. Future work
includes creating a framework for compressing streaming GPS
trajectory data.
REFERENCES
[1] A. Malinowski, J. Chen, S. K. Mishra, S. Samavedam, and D. Sohn,
“What is killing Moore’s law? Challenges in advanced FinFET technology
integration,” in The 26th International Conference Mixed Design of
Integrated Circuits and Systems (MIXDES), Rzesz´ ow, Poland, 2019, pp.
46–51.
[2] D. Douglas and T. Peucker, “Algorithms for the reduction of the number
of points required to represent a digitized line or its caricature,” Car-
tographica: The International Journal for Geographic Information and
Geovisualization, vol. 10, no. 2, pp. 112–122, 1973.
[3] W. Xue, C. Luo, G. Lan, R. Rana, W. Hu, and A. Seneviratne, “Kryptein:
A compressive-sensing-based encryption scheme for the internet of
things,” in The 16th ACM/IEEE International Conference on Information
Processing in Sensor Networks, Pittsburgh, PA, USA, 2017, pp. 169–180.
[4] W. Xue, C. Luo, R. Rana, W. Hu, and A. Seneviratne, “CScrypt: A
compressive-sensing-based encryption engine for the Internet of Things:
demo abstract,” in The 14th ACM Conference on Embedded Network
Sensor Systems CD-ROM (SenSys), Stanford, CA, USA, 2016, pp. 286–
287.
[5] R. Rana, M. Yang, T. Wark, C. Chou, and W. Hu, “SimpleTrack: Adaptive
trajectory compression with deterministic projection matrix for mobile
sensor networks,” IEEE Sensors Journal, vol. 15, pp. 365–373, 2014.
[6] J. Acharya and S. Gaur, “Edge compression of GPS data for mobile IoT,”
in The IEEE Fog World Congress (FWC), Santa Clara, CA, USA, 2017,
pp. 1–6.
[7] V. Patil and P. K. Atrey, “GeoSecure-R: Secure computation of geo-
graphical distance using region-anonymized GPS data,” in The 6th IEEE
International Conference on Multimedia Big Data (BigMM), New Delhi,
India, 2020, pp. 348–356.
[8] V. Patil, S. Parikh, P. Singh, and P. K. Atrey, “GeoSecure: Towards secure
outsourcing of GPS data over cloud,” in The 5th IEEE Conference on
Communications and Network Security (CNS), Las Vegas, NV, USA,
2017, pp. 495–501.
[9] V. Patil, S. B. Parikh, and P. K. Atrey, “GeoSecure-O: A method for secure
distance calculation for travel mode detection using outsourced GPS
trajectory data,” in The 5th IEEE International Conference on Multimedia
Big Data (BigMM), Singapore, 2019, pp. 348–356.
[10] A. Nibali and Z. He, “Trajic: An effective compression system for
trajectory data,” IEEE Transactions on Knowledge and Data Engineering,
vol. 27, no. 11, pp. 3138–3151, 2015.
[11] Y. Zheng, H. Fu, X. Xie, W.-Y. Ma, and Q. Li, Geolife
GPS Trajectory Dataset - User Guide, July 2011. [On-
line]. Available: https://www.microsoft.com/en-us/research/publication/
geolife-gps-trajectory-dataset-user-guide/
[12] G. Boeing. Reducing Spatial Data Set Size with Douglas-
Peucker. [Online]. Available: https://geoffboeing.com/2014/08/
reducing-spatial-data-set-size-with-douglas-peucker/
Authorized licensed use limited to: UNIVERSITY AT ALBANY SUNY. Downloaded on September 29,2022 at 17:57:06 UTC from IEEE Xplore. Restrictions apply.