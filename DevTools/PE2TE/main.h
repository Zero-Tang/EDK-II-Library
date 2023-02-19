#pragma once

BOOL ConvertToTerseExecutableImage(IN PVOID PeImage,OUT PVOID TeImage);
PVOID GetTeImageSection(IN PVOID TeImage,IN LONG32 Index,OUT PULONG32 SectionSize,OUT PULONG32 FileOffset);
